;; magit-range-diff.el --- File sections and colors for magit-tbdiff buffers  -*- lexical-binding: t; -*-

;; Makes `magit-tbdiff' range diff buffers read like regular Magit diffs:
;;
;; - The outer hunks of each commit pair are grouped into file sections.
;;   Outer hunks don't follow file boundaries, so each line is attributed to
;;   a file.  Each side of the outer diff tracks the file it is in through the
;;   headers on its side.  A `-' line belongs to the old side's file, a `+'
;;   line to the new side's and a context line to both.  When the sides
;;   disagree, lines of both files can interleave, so their section is named
;;   after both files.  Outer hunks are split where a line doesn't belong to
;;   the files of the current section.
;;
;; - With --dual-color, the inner diff's text color is left to Emacs, like in
;;   regular diffs, while the outer `-' and `+' markers keep git's.
;;   Backgrounds extend to the window edge.
;;
;; - Headings highlight like those of regular diffs, and code is syntax
;;   highlighted when `magit-diff-fontify-hunk' is non-nil.

(require 'ansi-color)
(require 'cl-lib)
(require 'diff-mode)
(require 'magit)
(require 'magit-tbdiff)

(defvar magit-range-diff-fontify-max-hunks 15
  "Syntax highlight a file's hunks only when it has at most this many.")

;;; Sections

;; Dual color hunks can't use `magit-hunk-section', whose painting would
;; replace their colors.
(defclass magit-range-diff-hunk-section (magit-section)
  ((heading-highlight-face :initform 'magit-diff-hunk-heading-highlight)
   (heading-selection-face :initform 'magit-diff-hunk-heading-selection)))

(defclass magit-range-diff-file-section (magit-section)
  ((heading-highlight-face :initform 'magit-diff-file-heading-highlight)
   (heading-selection-face :initform 'magit-diff-file-heading-selection)))

;;; Colors

(defun magit-range-diff--face-without-foreground (face)
  "FACE, a face or list of faces made by `ansi-color', without foreground."
  (cond ((keywordp (car-safe face))
         (cl-loop for (key value) on face by #'cddr
                  unless (eq key :foreground) nconc (list key value)))
        ((symbolp face) face)
        (t (delq nil (mapcar #'magit-range-diff--face-without-foreground
                             face)))))

(defun magit-range-diff--extend-face (face)
  "FACE, a face or list of faces, extended to the window edge."
  (cond ((keywordp (car-safe face)) (append face '(:extend t)))
        ((symbolp face) (list :inherit face :extend t))
        (t (mapcar #'magit-range-diff--extend-face face))))

(defun magit-range-diff--apply-face (beg end face)
  "Apply FACE from BEG to END, for `ansi-color-apply-face-function'.
Dual color lines have several runs, of which only the last extends to
the window edge."
  ;; The lines are still indented by four spaces at this point
  (let* ((outer (= (- beg (line-beginning-position)) 4))
         ;; Outer `-' and `+' markers are runs of their own
         (marker (and outer (= end (1+ beg))
                      (memq (char-after beg) '(?- ?+)))))
    (unless marker
      ;; Leave the inner diff's text color to Emacs, like regular diffs
      (setq face (magit-range-diff--face-without-foreground face))
      ;; Git colors outer context lines from the outer marker on, but that
      ;; column is about the outer diff, so leave it uncolored
      (when (and outer (eq (char-after beg) ?\s) (< (1+ beg) end))
        (setq beg (1+ beg))))
    ;; A marker is the last run when the inner line is empty, but its
    ;; highlight is about that column only
    (if (and face
             (not marker)
             (save-excursion
               (goto-char end)
               ;; Escape sequences are only removed after the face is applied
               (looking-at-p "\\(?:\e\\[[0-9;]*m\\)*$")))
        (overlay-put (ansi-color-make-extent
                      beg (min (point-max)
                               (save-excursion (goto-char end)
                                               (1+ (line-end-position)))))
                     'face (magit-range-diff--extend-face face))
      (ansi-color-apply-overlay-face beg end face))))

;;; File attribution

(defconst magit-range-diff--file-tag "\0tbdiff-file\0"
  "Prefix of the placeholder lines marking the start of a file section.")

(defconst magit-range-diff--pseudo-files '("Metadata" "Commit message")
  "Range-diff sections that use the file header format.")

(defconst magit-range-diff--file-header-re " ## \\(.*\\) ##"
  "A `## FILE ##' header as it appears in a patch, FILE in group 1.")

(defun magit-range-diff--known-files ()
  "Files touched by the commits of either range in the current buffer."
  (append magit-range-diff--pseudo-files
          (delete-dups
           (seq-mapcat (lambda (range)
                         (magit-git-lines "log" "--format=" "--name-only"
                                          range))
                       (list magit-tbdiff-buffer-range-a
                             magit-tbdiff-buffer-range-b)))))

(defun magit-range-diff--normalize (name)
  "Strip the annotations range-diff adds to the file NAME in its headers."
  (setq name (replace-regexp-in-string
              " (mode change [0-7]+ => [0-7]+)\\'" "" name))
  (setq name (replace-regexp-in-string " (\\(?:new\\|deleted\\))\\'" "" name))
  (if (string-match " => \\(.*\\)\\'" name) (match-string 1 name) name))

(defun magit-range-diff--resolve (text files current)
  "File in FILES that the section header TEXT refers to, or nil.
TEXT is \"FILE\" or \"FILE: CONTEXT\", possibly truncated by git to
80 characters.  Prefer CURRENT when the truncation is ambiguous."
  (let ((name (magit-range-diff--normalize text)))
    (or (car (sort (seq-filter (lambda (file)
                                 (or (equal name file)
                                     (string-prefix-p (concat file ":") text)))
                               files)
                   :key #'length :reverse t))
        (let ((candidates (seq-filter (lambda (file)
                                        (string-prefix-p text file))
                                      files)))
          (if (member current candidates) current (car candidates))))))

(defun magit-range-diff--header-file (inner files)
  "File named by the patch line INNER if it is a file or hunk header."
  (cond ((string-match (concat "\\`" magit-range-diff--file-header-re "\\'")
                       inner)
         ;; Could also be an unchanged code line, so only accept known files
         (car (member (magit-range-diff--normalize (match-string 1 inner))
                      files)))
        ((string-match "\\`@@ \\(.*\\)\\'" inner)
         (magit-range-diff--resolve (match-string 1 inner) files nil))))

(defun magit-range-diff--insert (&rest strings)
  "Insert STRINGS, clear of the dual color overlays that grow over them."
  (let ((beg (point)))
    (apply #'insert strings)
    (remove-overlays beg (point))))

(defun magit-range-diff--insert-file-tag (files &optional heading)
  "Insert a placeholder starting a section for FILES at point.
HEADING is (MARKER . TEXT) of the `## TEXT ##' line folded into the
section's heading, if any."
  (let ((name (string-join files " ⇄ ")))
    (magit-range-diff--insert magit-range-diff--file-tag name "\0"
                              (if heading (car heading) ?=)
                              (or (cdr heading) name) "\n")))

(defun magit-range-diff--annotate-files (files)
  "Insert file placeholders into the outer hunks of one commit pair."
  (goto-char (point-min))
  ;; PENDING is the hunk heading still owed to the lines of the current
  ;; section, inserted only once one of them stays in it
  (let (old new section hunk-beg hunk-heading pending)
    (while (not (eobp))
      (if (looking-at "^@@\\(?: \\(.*\\)\\)?$")
          (let* ((label (match-string-no-properties 1))
                 (file (and label
                            (magit-range-diff--resolve label files old))))
            (setq hunk-heading (match-string-no-properties 0))
            ;; Git takes the label from the old side.  If it isn't the old
            ;; side's file, its header is in the unchanged lines skipped
            ;; since the last hunk, which both sides share.
            (unless (or (not file) (equal file old))
              (setq old file)
              (setq new file))
            (setq hunk-beg (point))
            (setq pending nil)
            (forward-line))
        (let* ((marker (char-after))
               (inner (buffer-substring-no-properties
                       (min (1+ (point)) (line-end-position))
                       (line-end-position)))
               (header (magit-range-diff--header-file inner files))
               (line-files
                (pcase marker
                  (?\s (when header
                         (setq old header)
                         (setq new header))
                       (delete-dups (delq nil (list old new))))
                  (?- (when header (setq old header)) (and old (list old)))
                  (?+ (when header (setq new header)) (and new (list new)))))
               (heading (and header
                             (string-match
                              (concat "\\`" magit-range-diff--file-header-re
                                      "\\'")
                              inner)
                             (cons marker (match-string 1 inner)))))
          (when (and hunk-beg (not line-files))
            (setq line-files (or section '("?"))))
          (cond
           ((seq-every-p (lambda (file) (member file section)) line-files)
            (when pending
              (magit-range-diff--insert pending "\n")
              (setq pending nil))
            (forward-line))
           (heading
            ;; The `## FILE ##' line becomes the section heading, and the
            ;; hunk heading moves to the next line staying in the section
            (setq section line-files)
            (setq pending (if hunk-beg hunk-heading "@@ (continued)"))
            (delete-region (or hunk-beg (point)) (line-beginning-position 2))
            ;; Both versions touch the file but annotate it differently,
            ;; such as a mode change in one of them
            (when-let* (((memq marker '(?- ?+)))
                        ((looking-at (concat "^[-+]\\("
                                             magit-range-diff--file-header-re
                                             "\\)$")))
                        ((/= (char-after) marker))
                        (text (match-string-no-properties 2))
                        ((equal (magit-range-diff--header-file
                                 (match-string-no-properties 1) files)
                                header)))
              (if (eq marker ?-) (setq new header) (setq old header))
              (setq heading
                    (cons ?~ (if (eq marker ?-)
                                 (format "%s → %s" (cdr heading) text)
                               (format "%s → %s" text (cdr heading)))))
              (delete-region (point) (line-beginning-position 2)))
            (magit-range-diff--insert-file-tag section heading))
           (t
            (setq section line-files)
            (setq pending nil)
            (if hunk-beg
                ;; Keep the hunk whole rather than leave its heading behind
                (save-excursion
                  (goto-char hunk-beg)
                  (magit-range-diff--insert-file-tag section))
              (magit-range-diff--insert-file-tag section)
              (magit-range-diff--insert "@@ (continued)\n"))
            (forward-line)))
          (setq hunk-beg nil))))))

;;; Fontification

(defun magit-range-diff--code-lines (beg end)
  "Code lines between BEG and END as (BOL OUTER INNER EOL).
OUTER and INNER are the markers of the outer and inner diff."
  (let (lines)
    (save-excursion
      (goto-char beg)
      (while (< (point) end)
        (when (and (looking-at "^\\([-+ ]\\)\\([-+ ]\\)")
                   ;; A file header, not code
                   (not (looking-at
                         (concat "^." magit-range-diff--file-header-re "$"))))
          (push (list (point) (char-after) (char-after (1+ (point)))
                      (line-end-position))
                lines))
        (forward-line)))
    (nreverse lines)))

(defun magit-range-diff--fontify (section file)
  "Syntax highlight the code in the hunks of SECTION as FILE's code.
Each line is part of up to four versions of the code: the old or new
side of the outer diff and of the inner diff.  Fontify each version
separately, like Magit does for the two sides of a regular diff."
  (let ((lines (magit-range-diff--code-lines (oref section content)
                                             (oref section end)))
        (done (make-hash-table)))
    ;; Like Magit, prefer the newest version a line is part of
    (dolist (side '((?+ . ?+) (?+ . ?-) (?- . ?+) (?- . ?-)))
      (let* ((side-lines
              (seq-filter (lambda (line)
                            (and (memq (nth 1 line) (list ?\s (car side)))
                                 (memq (nth 2 line) (list ?\s (cdr side)))))
                          lines))
             (text (mapconcat (lambda (line)
                                (buffer-substring-no-properties
                                 (+ (nth 0 line) 2) (nth 3 line)))
                              side-lines "\n")))
        (cl-mapc
         (lambda (line props)
           (unless (gethash (car line) done)
             (puthash (car line) t done)
             (pcase-dolist (`(,b ,e ,face) props)
               (let ((o (make-overlay (+ (car line) 2 b) (+ (car line) 2 e)
                                      nil t)))
                 (overlay-put o 'evaporate t)
                 (overlay-put o 'face face)))))
         side-lines
         (with-temp-buffer
           ;; Fontifies the current buffer, TEXT is only for verification
           (insert text)
           (diff-syntax-fontify-props file text nil t)))))))

(defun magit-range-diff--add-detail (section)
  "Fontify the hunks of the file SECTION like regular diffs."
  (let ((files (split-string (oref section value) " ⇄ "))
        (hunks (oref section children)))
    (when (and magit-diff-fontify-hunk
               hunks
               (<= (length hunks) magit-range-diff-fontify-max-hunks)
               (not (seq-intersection files magit-range-diff--pseudo-files)))
      ;; The new side's file decides the mode
      (magit-range-diff--fontify section (car (last files))))))

;;; Washing

(defun magit-range-diff--wash-files (wash-sequence hunk-wash-fn files)
  "Wash one commit pair into file sections containing its hunks.
WASH-SEQUENCE is the original `magit-wash-sequence'.  FILES are the
files the ranges touch, from `magit-range-diff--known-files'."
  (magit-range-diff--annotate-files files)
  (goto-char (point-min))
  (let ((tag-re (concat "^" (regexp-quote magit-range-diff--file-tag))))
    (funcall
     wash-sequence
     (lambda ()
       (when (looking-at (concat tag-re "\\([^\0\n]*\\)\0\\(.\\)\\(.*\\)$"))
         (let ((files (match-string-no-properties 1))
               (kind (string-to-char (match-string-no-properties 2)))
               (text (match-string-no-properties 3))
               ;; Advance over the heading, inserted at `end' when the
               ;; section has no body
               (end (copy-marker
                     (save-excursion
                       (forward-line)
                       (if (re-search-forward tag-re nil t)
                           (match-beginning 0)
                         (point-max)))
                     t)))
           (magit-delete-line)
           (magit-range-diff--add-detail
            (magit-insert-section section (tbdiff-file files)
              (magit-range-diff--insert-file-heading kind text)
              (magit-insert-heading)
              (save-restriction
                (narrow-to-region (point) end)
                (funcall wash-sequence hunk-wash-fn))
              ;; Hunk headings are reinserted where the next line starts,
              ;; so its dual color overlay can grow over them.  The hunk
              ;; washer only clears them up to the newline.
              (dolist (hunk (oref section children))
                (remove-overlays (oref hunk start) (oref hunk content)))
              (goto-char end)))
           (set-marker end nil))
         t)))))

(defun magit-range-diff--insert-file-heading (kind text)
  "Insert the heading of a file section for TEXT.
KIND is the marker of the folded `## TEXT ##' line, ?~ if both versions'
lines were folded, or ?= if none."
  (magit-range-diff--insert
   (pcase kind
     (?+ (propertize "new only   " 'font-lock-face
                     'magit-diff-added-indicator))
     (?- (propertize "old only   " 'font-lock-face
                     'magit-diff-removed-indicator))
     (_ ""))
   (propertize text 'font-lock-face 'magit-diff-file-heading)
   "\n"))

(defun magit-range-diff--wash (wash args)
  "Around advice for `magit-tbdiff-wash' adding colors and file sections."
  ;; `magit-tbdiff-wash' only uses `magit-wash-sequence' to wash the hunks
  ;; of each commit pair, so hook in there
  (let ((wash-sequence (symbol-function 'magit-wash-sequence))
        (ansi-color-apply-face-function #'magit-range-diff--apply-face)
        ;; Once for all commit pairs, as each is washed separately
        (files (magit-range-diff--known-files)))
    (cl-letf (((symbol-function 'magit-wash-sequence)
               (lambda (hunk-wash-fn)
                 (magit-range-diff--wash-files wash-sequence hunk-wash-fn
                                               files))))
      (funcall wash args))))

;;; Mode

;;;###autoload
(define-minor-mode magit-range-diff-mode
  "Show range diffs with file sections, like regular Magit diffs."
  :global t
  :group 'magit-extensions
  (if magit-range-diff-mode
      (progn
        (setf (alist-get 'tbdiff-hunk magit--section-type-alist)
              'magit-range-diff-hunk-section)
        (setf (alist-get 'tbdiff-file magit--section-type-alist)
              'magit-range-diff-file-section)
        (advice-add 'magit-tbdiff-wash :around #'magit-range-diff--wash))
    (setf (alist-get 'tbdiff-hunk magit--section-type-alist nil t) nil)
    (setf (alist-get 'tbdiff-file magit--section-type-alist nil t) nil)
    (advice-remove 'magit-tbdiff-wash #'magit-range-diff--wash)))

(provide 'magit-range-diff)
