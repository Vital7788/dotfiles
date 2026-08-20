;;; magit-diffstat-tree.el --- Group magit diffstat entries into a collapsible tree  -*- lexical-binding: t; -*-

;; Replaces the flat list of files in magit's `diffstat' section with nested
;; `directory' sections, so that whole folders can be collapsed with TAB.
;;
;; The diff sections below the diffstat are deliberately left flat: magit
;; looks those up by the hard-coded lineage (file . NAME) -> root section,
;; so nesting them would break staging, `magit-diff-visit-file' and friends.

(require 'magit)
(require 'cl-lib)

(defvar magit-diffstat-tree-indent 2
  "Number of spaces per nesting level.")

(defvar magit-diffstat-tree-file-format 'numbers
  "How to show the changed line counts of a file.
`numbers\=' shows \"+2 -1\", like the directory headings do; `graph\=' shows
git\='s own \"3 ++-\" histogram, like magit does by default.")

(defvar magit-diffstat-tree-collapse-single-child t
  "Whether to merge chains of single-child directories into one section,
i.e. show \"src/main/java\" as one heading instead of three nested ones.")

;;; Parsing

(defun magit-diffstat-tree--split-rename (file)
  "Return (NEW-PATH . OLD-PATH) for FILE, a path as printed by --numstat.
OLD-PATH is nil unless FILE describes a rename."
  (cond ((string-match "{\\(.*\\) => \\(.*\\)}" file)
         (cons (replace-match (match-string 2 file) nil t file)
               (replace-match (match-string 1 file) nil t file)))
        ((string-match "\\(.*\\) => \\(.*\\)" file)
         (cons (match-string 2 file) (match-string 1 file)))
        (t (cons file nil))))

(defun magit-diffstat-tree--wash ()
  "Replacement for `magit-diff-wash-diffstat' that groups files by directory."
  (let (heading (beg (point)))
    (when (re-search-forward "^ ?\\([0-9]+ +files? change[^\n]*\n\\)" nil t)
      (setq heading (match-string 1))
      (magit-delete-match)
      (goto-char beg)
      (magit-insert-section (diffstat)
        (magit-insert-heading
          (propertize heading 'font-lock-face 'magit-diff-file-heading))
        (let (records)
          ;; --numstat lines: added, deleted, path.  Paths are not abbreviated
          ;; here (unlike in --stat), so the tree is built from these.
          (while (looking-at "^\\([-0-9]+\\)\t\\([-0-9]+\\)\t\\(.+\\)$")
            ;; Read the groups before calling out; `string-match' inside
            ;; `magit-diffstat-tree--split-rename' clobbers the match data.
            (let ((nadd (and (not (equal (match-string 1) "-")) ; "-" for binary
                             (string-to-number (match-string 1))))
                  (ndel (and (not (equal (match-string 2) "-"))
                             (string-to-number (match-string 2))))
                  (file (match-string-no-properties 3)))
              (pcase-let ((`(,new . ,old) (magit-diffstat-tree--split-rename file)))
                (push (list (magit-decode-git-path new)
                            (and old (magit-decode-git-path old))
                            nadd ndel
                            nil nil nil) ; cnt, "+++" bar, "---" bar
                      records)))
            (magit-delete-line))
          (setq records (nreverse records))
          ;; --stat lines only contribute the "12 ++++--" graph.
          (let ((rest records))
            (while (looking-at magit-diff-statline-re)
              (magit-bind-match-strings (_file _sep cnt add del) nil
                (when rest
                  (setcar (nthcdr 4 (car rest)) cnt)
                  (setcar (nthcdr 5 (car rest)) add)
                  (setcar (nthcdr 6 (car rest)) del)
                  (setq rest (cdr rest)))
                (magit-delete-line))))
          (let ((nodes (magit-diffstat-tree--build
                        (mapcar (lambda (r) (cons (car r) r)) records)
                        "" 0)))
            (magit-diffstat-tree--insert
             nodes (magit-diffstat-tree--metrics nodes))))
        (if (looking-at "^$") (forward-line) (insert "\n"))))))

;;; Tree building

(cl-defstruct (magit-diffstat-tree-node (:constructor magit-diffstat-tree-node)
                                        (:copier nil))
  "A directory or file entry of the diffstat.
LABEL is the formatted, propertized display name without indentation, so
that its width is known even when `magit-format-file-function' adds icons."
  kind depth name label path children
  nadd ndel                             ; directories and files
  cnt add del)                          ; files only: git's "12 ++--" graph

(defun magit-diffstat-tree--build (items prefix depth)
  "Group ITEMS, a list of (RELATIVE-PATH . RECORD), one level at a time.
PREFIX is the directory ITEMS are relative to, DEPTH its nesting level."
  (let (dirs files)
    (dolist (item items)
      (if (string-match "\\`\\([^/]+\\)/" (car item))
          (let* ((dir (match-string 1 (car item)))
                 (rest (substring (car item) (match-end 0)))
                 (cell (assoc dir dirs)))
            (unless cell
              (setq cell (list dir))
              (push cell dirs))
            (setcdr cell (cons (cons rest (cdr item)) (cdr cell))))
        (push (magit-diffstat-tree--file-node (cdr item) (car item) depth)
              files)))
    (append
     (mapcar (lambda (cell) (magit-diffstat-tree--dir-node cell prefix depth))
             (nreverse dirs))
     (nreverse files))))

(defun magit-diffstat-tree--dir-node (cell prefix depth)
  (let* ((name (car cell))
         (path (concat prefix name "/"))
         (children (magit-diffstat-tree--build
                    (nreverse (cdr cell)) path (1+ depth))))
    ;; Merge chains of single-child directories into one section.
    (while (and magit-diffstat-tree-collapse-single-child
                (null (cdr children))
                (eq (magit-diffstat-tree-node-kind (car children)) 'dir))
      (let ((child (car children)))
        (setq name (concat name "/" (magit-diffstat-tree-node-name child)))
        (setq path (magit-diffstat-tree-node-path child))
        (setq children (magit-diffstat-tree--lift
                        (magit-diffstat-tree-node-children child)))))
    (pcase-let ((`(,nadd ,ndel) (magit-diffstat-tree--sum children)))
      (magit-diffstat-tree-node
       :kind 'dir :depth depth :name name :path path :children children
       :label (magit-format-file 'stat (concat name "/")
                                 'magit-diff-file-heading)
       :nadd nadd :ndel ndel))))

(defun magit-diffstat-tree--file-node (record name depth)
  (pcase-let ((`(,path ,orig ,nadd ,ndel ,cnt ,add ,del) record))
    (magit-diffstat-tree-node
     :kind 'file :depth depth :name name :path path
     :label (magit-format-file
             'stat name 'magit-filename nil
             ;; Show just the old basename when the file did not move.
             (and orig (if (equal (file-name-directory orig)
                                  (file-name-directory path))
                           (file-name-nondirectory orig)
                         orig)))
     :nadd nadd :ndel ndel :cnt cnt :add add :del del)))

(defun magit-diffstat-tree--lift (nodes)
  "Decrease the depth of NODES and their descendants by one."
  (dolist (node nodes)
    (cl-decf (magit-diffstat-tree-node-depth node))
    (magit-diffstat-tree--lift (magit-diffstat-tree-node-children node)))
  nodes)

(defun magit-diffstat-tree--sum (nodes)
  "Return (NADD NDEL) for NODES and their descendants."
  (cl-flet ((total (slot)
              (apply #'+ (mapcar (lambda (node) (or (funcall slot node) 0))
                                 nodes))))
    (list (total #'magit-diffstat-tree-node-nadd)
          (total #'magit-diffstat-tree-node-ndel))))

;;; Insertion

(defun magit-diffstat-tree--metrics (nodes)
  "Return the column widths (LABEL ADDED REMOVED) needed by NODES."
  (let ((lw 0) (aw 0) (dw 0))
    (dolist (node nodes)
      (setq lw (max lw (+ (* (magit-diffstat-tree-node-depth node)
                             magit-diffstat-tree-indent)
                          (length (magit-diffstat-tree-node-label node)))))
      (when-let ((counts (magit-diffstat-tree--counts node)))
        (setq aw (max aw (length (car counts))))
        (setq dw (max dw (length (cdr counts)))))
      (pcase-let ((`(,l ,a ,d) (magit-diffstat-tree--metrics
                                (magit-diffstat-tree-node-children node))))
        (setq lw (max lw l) aw (max aw a) dw (max dw d))))
    (list lw aw dw)))

(defun magit-diffstat-tree--counts (node)
  "Return (\"+N\" . \"-N\") for NODE, or nil if it has no line counts.
Binary files have none, and neither do files shown as a histogram."
  (and (or (eq (magit-diffstat-tree-node-kind node) 'dir)
           (eq magit-diffstat-tree-file-format 'numbers))
       (magit-diffstat-tree-node-nadd node)
       (cons (format "+%d" (magit-diffstat-tree-node-nadd node))
             (format "-%d" (magit-diffstat-tree-node-ndel node)))))

(defun magit-diffstat-tree--insert (nodes metrics)
  (pcase-let ((`(,lw ,aw ,dw) metrics))
    (dolist (node nodes)
      (let* ((dirp (eq (magit-diffstat-tree-node-kind node) 'dir))
             (indent (* (magit-diffstat-tree-node-depth node)
                        magit-diffstat-tree-indent))
             (label (magit-diffstat-tree-node-label node))
             (counts (magit-diffstat-tree--counts node))
             (line (concat
                    (make-string indent ?\s)
                    label
                    (make-string (max 1 (1+ (- lw indent (length label)))) ?\s)
                    "| "
                    (cond
                     (counts
                      ;; Right-align the numbers, but keep the padding
                      ;; outside the faces.
                      (concat (make-string (- aw (length (car counts))) ?\s)
                              (magit--propertize-face
                               (car counts) 'magit-diffstat-added)
                              " "
                              (make-string (- dw (length (cdr counts))) ?\s)
                              (magit--propertize-face
                               (cdr counts) 'magit-diffstat-removed)))
                     ;; A binary file, or one shown as a histogram.
                     ((not dirp)
                      (let ((add (or (magit-diffstat-tree-node-add node) ""))
                            (del (or (magit-diffstat-tree-node-del node) "")))
                        (concat (magit-diffstat-tree-node-cnt node)
                                (and (or (length> add 0) (length> del 0)) " ")
                                (magit--propertize-face
                                 add 'magit-diffstat-added)
                                (magit--propertize-face
                                 del 'magit-diffstat-removed))))))))
        (if dirp
            (magit-insert-section (directory (magit-diffstat-tree-node-path node))
              (magit-insert-heading line)
              (magit-diffstat-tree--insert
               (magit-diffstat-tree-node-children node) metrics))
          (magit-insert-section (file (magit-diffstat-tree-node-path node))
            (insert line "\n")))))))

;;; Making magit's diffstat commands cope with the extra nesting
;;
;; Magit matches diffstat entries with the hard-coded lineage [file diffstat];
;; with directory sections in between that no longer matches.

(defun magit-diffstat-tree--diffstat ()
  (cl-find-if (lambda (s) (eq (oref s type) 'diffstat))
              (oref magit-root-section children)))

(defun magit-diffstat-tree--find-file (section value)
  "Find the `file' section for VALUE anywhere below SECTION."
  (catch 'found
    (dolist (child (oref section children))
      (if (and (eq (oref child type) 'file)
               (equal (oref child value) value))
          (throw 'found child)
        (when-let ((hit (magit-diffstat-tree--find-file child value)))
          (throw 'found hit))))
    nil))

(defun magit-diffstat-tree--files (section)
  "Return the values of all `file' sections below SECTION."
  (mapcan (lambda (child)
            (if (eq (oref child type) 'file)
                (list (oref child value))
              (magit-diffstat-tree--files child)))
          (oref section children)))

(defun magit-diffstat-tree--get-diffs (fn sections)
  "Make staging and unstaging work from a nested diffstat entry."
  (if (magit-section-match '[file * diffstat] (car sections))
      (mapcar (lambda (section)
                (or (magit-get-section
                     (append `((file . ,(oref section value)))
                             (magit-section-ident magit-root-section)))
                    (error "Cannot get required diff headers")))
              sections)
    (funcall fn sections)))

(defun magit-diffstat-tree--toggle (fn section)
  "Collapse the folder a diffstat entry is in, rather than the entry itself.
Diffstat entries have no body of their own, so toggling them does nothing."
  (if (and (magit-section-match '[file directory] section)
           (null (oref section children)))
      (let ((parent (oref section parent)))
        (magit-section-hide parent)
        (goto-char (oref parent start)))
    (funcall fn section)))

(defun magit-diffstat-tree--goto (target &optional top)
  (unless target
    (user-error "No corresponding section"))
  (magit-section-reveal target)
  (goto-char (oref target start))
  ;; With TOP, show the target at the top of the window instead of letting
  ;; Emacs recenter
  (when top
    (when-let ((window (get-buffer-window (current-buffer))))
      (set-window-start window (point)))))

(defun magit-diffstat-tree-jump ()
  "Jump from a diffstat entry to the corresponding diff, or back."
  (interactive)
  (let ((section (magit-current-section))
        (diffstat (or (magit-diffstat-tree--diffstat)
                      (user-error "No diffstat in this buffer"))))
    (if (magit-section-match '[file * diffstat] section)
        ;; Inside the diffstat: go to the real diff, shown from its top.
        (magit-diffstat-tree--goto
         (magit-get-section
          (append `((file . ,(oref section value)))
                  (magit-section-ident magit-root-section)))
         t)
      ;; In a diff: go to the matching diffstat entry.
      (magit-diffstat-tree--goto
       (cond
        ((magit-section-match 'file section)
         (magit-diffstat-tree--find-file diffstat (oref section value)))
        ((magit-section-match 'hunk section)
         (magit-diffstat-tree--find-file
          diffstat (magit-section-parent-value section)))
        (t diffstat))))))

(defun magit-diffstat-tree-jump-to-diffstat ()
  "Go to the diffstat, or to the entry for the file at point."
  (interactive)
  (let ((section (magit-current-section))
        (diffstat (or (magit-diffstat-tree--diffstat)
                      (user-error "No diffstat in this buffer"))))
    (magit-diffstat-tree--goto
     (or (and (not (magit-section-match '[file * diffstat] section))
              (magit-diffstat-tree--find-file
               diffstat (pcase (oref section type)
                          ('file (oref section value))
                          ('hunk (magit-section-parent-value section)))))
         diffstat))))

;;; Acting on a whole directory

(defun magit-diffstat-tree-stage-directory ()
  "Stage every change below the `directory' section at point."
  (interactive)
  (magit-stage-files (magit-diffstat-tree--files (magit-current-section))))

(defun magit-diffstat-tree-unstage-directory ()
  "Unstage every change below the `directory' section at point."
  (interactive)
  (magit-unstage-files (magit-diffstat-tree--files (magit-current-section))))

(defvar-keymap magit-directory-section-map
  :doc "Keymap for `directory' sections in a diffstat."
  "s" #'magit-diffstat-tree-stage-directory
  "u" #'magit-diffstat-tree-unstage-directory)

;;;###autoload
(define-minor-mode magit-diffstat-tree-mode
  "Show diffstat entries as a collapsible directory tree."
  :global t
  :group 'magit-diff
  (cond
   (magit-diffstat-tree-mode
    (advice-add 'magit-diff-wash-diffstat :override #'magit-diffstat-tree--wash)
    (advice-add 'magit-apply--get-diffs :around #'magit-diffstat-tree--get-diffs)
    (advice-add 'magit-jump-to-diffstat-or-diff
                :override #'magit-diffstat-tree-jump)
    (advice-add 'magit-jump-to-revision-diffstat
                :override #'magit-diffstat-tree-jump-to-diffstat)
    (advice-add 'magit-section-toggle :around #'magit-diffstat-tree--toggle))
   (t
    (advice-remove 'magit-diff-wash-diffstat #'magit-diffstat-tree--wash)
    (advice-remove 'magit-apply--get-diffs #'magit-diffstat-tree--get-diffs)
    (advice-remove 'magit-jump-to-diffstat-or-diff #'magit-diffstat-tree-jump)
    (advice-remove 'magit-jump-to-revision-diffstat
                   #'magit-diffstat-tree-jump-to-diffstat)
    (advice-remove 'magit-section-toggle #'magit-diffstat-tree--toggle))))

(provide 'magit-diffstat-tree)
