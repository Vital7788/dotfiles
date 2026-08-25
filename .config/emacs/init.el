;; -*- lexical-binding: t; -*-
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;;; Set up package manager

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Don't show byte compilation warnings after installing packages
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; Local packages, not installed through `package'
(add-to-list 'load-path (locate-user-emacs-file "lisp"))

;;; Basic behavior

(setq inhibit-startup-screen t)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.local/state/emacs/
(setq backup-directory-alist '(("." . "~/.local/state/emacs/backup")))
(setq auto-save-file-name-transforms '((".*" "~/.local/state/emacs/autosave/\\1" t)))
(make-directory "~/.local/state/emacs/autosave/" t)

(setq-default indent-tabs-mode nil)
(setq tab-width 4)

(use-package whitespace
  :ensure nil
  :config
  (setq whitespace-style '(face tabs tab-mark trailing))
  (setq whitespace-display-mappings '((tab-mark ?\t [?» ?\t])))
  :hook
  (prog-mode-hook . whitespace-mode))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(show-paren-mode 1)

(setq scroll-step 1)
(setq scroll-margin 1)

(setq window-combination-resize t)
(setq help-window-select t)

(global-auto-revert-mode 1)

;; Enable indentation+completion using the TAB key.
(setq tab-always-indent 'complete)
(setq completion-cycle-threshold 5)

;; Emacs 30 and newer: Disable Ispell completion function.
;; Try `cape-dict' as an alternative.
;; (setq text-mode-ispell-word-completion nil)

;; Hide commands in M-x which do not apply to the current mode.
(setq read-extended-command-predicate #'command-completion-default-include-p)

(use-package exec-path-from-shell
  :ensure t
  :config
  (dolist (var '("VSCODE_EXTENSION_PATH" "VSCODE_DATA_DIR"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

;;;; Outline folding
(setq outline-minor-mode-cycle nil)

(defun my/outline-cycle ()
  "Cycle the current section: subheadings, then everything, then hidden.
Like `outline-cycle', except the intermediate state also shows the heading's
own body."
  (save-excursion
    (outline-back-to-heading)
    (pcase (outline--cycle-state)
      ('hide-all
       (if (outline-has-subheading-p)
           (progn (outline-show-entry)
                  (outline-show-children)
                  (message "Subheadings"))
         (outline-show-subtree)
         (message "Show all")))
      ('headings-only
       (outline-show-subtree)
       (message "Show all"))
      ('show-all
       (outline-hide-subtree)
       (message "Hide all")))))

(defun my/outline-cycle-buffer ()
  "Cycle the whole buffer: `;;;' headings, then all headings, then everything.
Like `outline-cycle-buffer', except the middle state applies `my/outline-cycle'
to every section rather than calling `outline-hide-region-body'."
  (interactive)
  (pcase outline--cycle-buffer-state
    ('show-all
     (outline-hide-sublevels 1)
     (setq outline--cycle-buffer-state 'top-level)
     (message "Top level headings"))
    ('top-level
     (outline-show-all)
     (save-excursion
       (goto-char (point-min))
       (while (outline-next-heading)
         (when (> (funcall outline-level) 1)
           (outline-hide-entry))))
     (setq outline--cycle-buffer-state 'all-heading)
     (message "Headings and top level code"))
    (_
     (outline-show-all)
     (setq outline--cycle-buffer-state 'show-all)
     (message "Show all"))))

(defun my/outline-cycle-dwim ()
  "Cycle the section point is inside, wherever point sits within it.
`outline-back-to-heading' finds the enclosing heading from anywhere in its
body, but errors above the first one, so cycle the whole buffer there
instead."
  (interactive)
  (if (or (outline-on-heading-p t)
          (save-excursion (outline-previous-heading)))
      (my/outline-cycle)
    (my/outline-cycle-buffer)))

;;; Appearance

;; More theme customizations: https://www.gnu.org/software/emacs/manual/html_node/modus-themes/DIY-Stylistic-variants-using-palette-overrides.html
;; Suble underlines
(setq modus-themes-common-palette-overrides
      '((underline-link border)
        (underline-link-visited border)
        (underline-link-symbolic border)))
(load-theme 'modus-operandi-tinted)

(let ((mono-spaced-font "IBM Plex Mono")
      (proportionately-spaced-font "IBM Plex Serif"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 105 :weight 'light)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0 :weight 'light)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0 :weight 'normal)
  (set-fontset-font t 'unicode (font-spec :name "Symbols Nerd Font Mono") nil 'append))

(blink-cursor-mode 0)

(global-visual-line-mode 1) ; wrap lines
(global-visual-wrap-prefix-mode 1)
(setq visual-line-fringe-indicators '(left-curly-arrow nil))

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

;;; Evil
(use-package dash
  :ensure t)

(use-package evil
  :after dash
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  (define-key evil-insert-state-map (kbd "C-SPC") 'completion-at-point)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "DEL") nil)
  (evil-define-key 'normal outline-minor-mode-map
    (kbd "TAB") #'my/outline-cycle-dwim
    (kbd "<backtab>") #'my/outline-cycle-buffer)

  (setq evil-symbol-word-search t)
  (setq evil-move-beyond-eol t)

  (add-hook 'evil-insert-state-entry-hook (lambda () (unless (display-graphic-p) (send-string-to-terminal "\033[6 q"))))
  (add-hook 'evil-insert-state-exit-hook  (lambda () (unless (display-graphic-p) (send-string-to-terminal "\033[2 q")))))

(use-package evil-collection
  :after evil
  :ensure t
  :hook (after-init . evil-collection-init))

(use-package evil-commentary
  :after evil
  :ensure t
  :hook (after-init . evil-commentary-mode))

(use-package xclip
  :after evil
  :ensure t
  :hook (after-init . xclip-mode))

;;; Project
(use-package project
  :ensure nil
  :config
  ;; Custom project folder
  (defun my/project-find-vscode (path)
    (when-let* ((folder "com.sigasi.lsp.extension.vscode")
                (index (string-match folder path)))
      (cons 'transient (substring path 0 (+ index (length folder))))))
  (add-to-list 'project-find-functions #'my/project-find-vscode))

;;; Minibuffer and Completions
;; More advanced stuff here: https://protesilaos.com/codelog/2024-02-17-emacs-modern-minibuffer-packages/

(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :config
  (defun my/vertico-kill-buffer ()
    "Kill the buffer of the selected candidate. Falls back to
`delete-forward-char' when the candidate is not a buffer."
    (interactive)
    (require 'embark)
    (let ((target (car (embark--targets))))
      (if (not (eq (plist-get target :type) 'buffer))
          (call-interactively #'delete-forward-char)
        ;; `kill-buffer' has an `embark--confirm' pre-action hook; suppress it
        ;; and let `kill-buffer' prompt on its own for unsaved changes.  The
        ;; `embark--restart' post-action hook refreshes the candidate list.
        (let ((embark-pre-action-hooks (cons '(kill-buffer ignore)
                                             embark-pre-action-hooks)))
          (embark--act #'kill-buffer target)))))
  (keymap-set vertico-map "<delete>" #'my/vertico-kill-buffer))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

(use-package consult
  :after evil
  :ensure t
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; A recursive grep
  (define-key evil-normal-state-map (kbd ",s") 'consult-ripgrep)
  ;; Search for files names recursively
  (define-key evil-normal-state-map (kbd ",f") 'consult-fd)
  ;; Search through the outline (headings) of the file
  (define-key evil-normal-state-map (kbd ",o") 'consult-outline)
  ;; Search the current buffer
  (define-key evil-normal-state-map (kbd ",l") 'consult-line)
  ;; Switch to another buffer, or bookmarked file, or recently opened file.
  (define-key evil-normal-state-map (kbd ",b") 'consult-buffer)

  (consult-customize consult-fd :state (consult--file-preview))

  (add-to-list 'consult-buffer-filter "\\`\\*scratch\\*\\'")
  (add-to-list 'consult-buffer-filter "\\`\\*Messages\\*\\'")
  (add-to-list 'consult-buffer-filter "\\`\\*Warnings\\*\\'")
  (add-to-list 'consult-buffer-filter "\\`\\*Async-native-compile-log\\*\\'")
  (add-to-list 'consult-buffer-filter "\\`\\*dape")
  (add-to-list 'consult-buffer-filter "\\`magit-process: ")

  (defvar my/consult-git-repos-cache
    (progn
      (bookmark-maybe-load-default-file)
      (cons (cons "dotfiles" (expand-file-name "~/"))
            (delq nil (mapcar (lambda (name)
                                (let ((dir (bookmark-get-filename name)))
                                  (when (and dir (file-exists-p (expand-file-name ".git" dir)))
                                    (cons name dir))))
                              (bookmark-all-names)))))
    "Alist of (BOOKMARK-NAME . DIR)")

  (defun my/magit-status-reuse (dir)
    "Display magit status buffer if it exists. Call magit-status otherwise."
    (require 'magit)
    (let* ((default-directory dir)
           (buffer (and (magit-toplevel)
                        (magit-get-mode-buffer 'magit-status-mode))))
      (if buffer
          (magit-display-buffer buffer)
        (magit-status dir))))

  (defvar my/consult-source-git-repos
    (list :name   "Git Repositories"
          :narrow ?g
          :items  (lambda () (mapcar #'car my/consult-git-repos-cache))
          :action (lambda (name)
                    (my/magit-status-reuse
                     (cdr (assoc name my/consult-git-repos-cache))))))
  (setq consult-buffer-sources
        (let (result)
          (dolist (source consult-buffer-sources (nreverse result))
            (unless (eq source 'my/consult-source-git-repos)
              (when (eq source 'consult-source-bookmark)
                (push 'my/consult-source-git-repos result))
              (push source result)))))

  (defun my/consult-magit-repos ()
    "Select a git repository (from bookmarks) with consult and open it in magit."
    (interactive)
    (my/magit-status-reuse
     (cdr (assoc (consult--read
                  (mapcar #'car my/consult-git-repos-cache)
                  :prompt "Repository: "
                  :sort nil
                  :require-match t)
                 my/consult-git-repos-cache))))
  (define-key evil-normal-state-map (kbd ",g") #'my/consult-magit-repos))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act) ; find relevant commands while over something
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult
  :ensure t)

(unless (>= emacs-major-version 31)
  (use-package wgrep
    :ensure t
    :config
    (setq wgrep-auto-save-buffer t)))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :config
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)
  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'
  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package cape
  :ensure t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  :bind ("M-SPC" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;;; File manager (Dired)

(use-package dired
  :ensure nil
  :commands (dired)
  :bind
  ("C-x C-d" . dired-jump)
  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (evil-define-key 'normal dired-mode-map
    (kbd "h") #'dired-up-directory
    (kbd "l") #'dired-find-file))

(use-package dired-preview
  :ensure t
  :after dired
  :hook (after-init . dired-preview-global-mode)
  :config
  (setq dired-preview-delay 0))

;;; Magit
(use-package magit
  :ensure t
  :init
  (setq magit-define-global-key-bindings 'recommended)
  (setq magit-diff-specify-hunk-foreground nil)
  :config
  (setq magit-list-refs-sortby "-committerdate"))

;;;; Magit: diff
;;;;; Display buffer
(use-package magit
  :ensure nil
  :config
  (defun my/magit-display-buffer-same-window (buffer)
    "Display BUFFER in the selected window, unless magit wants it beside it."
    (display-buffer buffer
                    (if magit-display-buffer-noselect
                        '(nil (inhibit-same-window . t))
                      '(display-buffer-same-window))))
  (setq magit-display-buffer-function #'my/magit-display-buffer-same-window))

;;;;; Transient
(use-package magit
  :ensure nil
  :config
  (defun my/magit-diff-origin-master (&optional args files)
    "Diff the current branch against origin's default branch."
    (interactive (magit-diff-arguments))
    (let ((main (or (magit-git-string "symbolic-ref" "--short"
                                      "refs/remotes/origin/HEAD")
                    "origin/master")))
      (magit-diff-setup-buffer (concat main "...") nil args files 'committed)))
  (transient-append-suffix 'magit-diff "r"
    '("o" "Diff origin/master..." my/magit-diff-origin-master)))

;;;;; Colors
(use-package magit
  :ensure nil
  :config
  (put 'magit-status-mode 'magit-diff-default-arguments
       '("--no-ext-diff" "--color-moved=zebra"))
  (put 'magit-diff-mode 'magit-diff-default-arguments
       '("--stat" "--no-ext-diff" "--color-moved=zebra"))
  (put 'magit-revision-mode 'magit-diff-default-arguments
       '("--stat" "--no-ext-diff" "--color-moved=zebra"))
  (put 'magit-stash-mode 'magit-diff-default-arguments
       '("--no-ext-diff" "--color-moved=zebra"))

  (setq magit-diff-use-indicator-faces t)
  (custom-set-faces
   '(magit-diff-removed           ((t :background "#e6c8c8" :foreground unspecified)))
   '(magit-diff-removed-highlight ((t :background "#e6c8c8" :foreground unspecified)))
   '(magit-diff-added             ((t :background "#d0d6cd" :foreground unspecified)))
   '(magit-diff-added-highlight   ((t :background "#d0d6cd" :foreground unspecified)))
   '(diff-refine-removed          ((t :background "#d69fa2" :foreground unspecified)))
   '(diff-refine-added            ((t :background "#aabbab" :foreground unspecified)))
   '(magit-diff-removed-indicator ((t :foreground "#8c1d28")))
   '(magit-diff-added-indicator   ((t :foreground "#30583c")))
   '(magit-diff-base-indicator    ((t :foreground "#302b5d"))))

  (defun my/magit-color-moved-extend-face (face)
    (cond ((keywordp (car-safe face)) (append face '(:extend t)))
          ((symbolp face) (list :inherit face :extend t))
          (t (mapcar #'my/magit-color-moved-extend-face face))))

  (defun my/magit-color-moved-apply-face (beg end face)
    (when face
      (overlay-put (ansi-color-make-extent
                    beg (save-excursion
                          (goto-char end)
                          (min (point-max) (1+ (line-end-position)))))
                   'face (my/magit-color-moved-extend-face face))))

  ;; extend `--color-moved' faces to the window edge
  (defun my/magit-color-moved-extend (fn &rest args)
    (let ((ansi-color-apply-face-function #'my/magit-color-moved-apply-face))
      (apply fn args)))
  (advice-add 'magit-diff-wash-diffs :around #'my/magit-color-moved-extend))

;;;;; Performance
(use-package magit
  :ensure nil
  :config
  (defvar my/magit-diff-detail-max-size 100000
    "Buffers larger than this many characters get no inline diffs or syntax highlighting.")

  (defun my/magit-diff-set-detail ()
    "Refine and fontify hunks, unless this buffer's diff is a large one."
    (when (derived-mode-p 'magit-mode)
      (let ((detail (and (<= (buffer-size) my/magit-diff-detail-max-size)
                         'all)))
        (setq-local magit-diff-refine-hunk 'all)
        (setq-local magit-diff-fontify-hunk 'all))))
  (add-hook 'magit-refresh-buffer-hook #'my/magit-diff-set-detail)

  (defun my/larger-heap-allocation (fn &rest args)
    "More heap allocation to speed up large diffs"
    (let ((gc-cons-percentage 0.6))
      (apply fn args)))
  (advice-add 'magit-refresh-buffer :around #'my/larger-heap-allocation))

;;;;; Whitespace
(use-package magit
  :ensure nil
  :config
  ;; Magit paints the leading tabs of a hunk with a `display' property so they
  ;; occupy exactly `tab-width' columns (see `magit-diff-paint-tab'). A
  ;; `display' property wins over `whitespace-mode's display table, which is why
  ;; tab markers never appear in diffs.
  (defun my/magit-diff-paint-tab (merging width)
    "Render leading tabs in diff hunks as a marker WIDTH columns wide."
    (save-excursion
      (forward-char (if merging 2 1))
      (while (= (char-after) ?\t)
        (put-text-property (point) (1+ (point)) 'display
                           (concat (propertize "»" 'face 'whitespace-tab)
                                   (make-string (max 0 (1- width)) ?\s)))
        (forward-char))))
  (advice-add 'magit-diff-paint-tab :override #'my/magit-diff-paint-tab)

  (defun my/magit-diff-show-whitespace ()
    (setq-local whitespace-style '(tab-mark))
    (whitespace-mode 1))
  (dolist (hook '(magit-diff-mode-hook
                  magit-revision-mode-hook
                  magit-status-mode-hook))
    (add-hook hook #'my/magit-diff-show-whitespace)))

;;;;; Pairwise hunk refinement
;; `diff--refine-hunk' word-diffs a whole run of removed lines against the
;; whole run of added lines, so matches span line boundaries and unrelated
;; rewrites still get refined on coincidental words.  Pair the Nth removed
;; line with the Nth added line instead, and refine a pair only when the two
;; are close enough.
(use-package magit
  :ensure nil
  :config
  (require 'diff-mode)
  (require 'smerge-mode)

  (defvar my/magit-diff-refine-max-line-distance 0.6
    "Maximum normalized edit distance for two lines to be refined as a pair.")

  (defun my/magit-diff--collect-lines (char bound)
    "Collect (BEG . END) of consecutive lines from point starting with CHAR."
    (let (lines)
      (while (and (< (point) bound) (eql (following-char) char))
        (push (cons (point) (progn (forward-line 1) (point))) lines))
      (nreverse lines)))

  (defun my/magit-diff--line-text (beg end)
    "Text of line BEG..END without its diff marker or trailing newline."
    (buffer-substring-no-properties
     (min end (1+ beg))
     (if (eq (char-before end) ?\n) (1- end) end)))

  (defun my/magit-diff--lines-similar-p (del add)
    (let* ((a (my/magit-diff--line-text (car del) (cdr del)))
           (b (my/magit-diff--line-text (car add) (cdr add)))
           (len (max (length a) (length b))))
      (or (zerop len)
          (<= (/ (string-distance a b) (float len))
              my/magit-diff-refine-max-line-distance))))

  (defun my/magit-diff--refine-line-pairs (beg end)
    "Refine removed/added lines in BEG..END pairwise, skipping distant pairs."
    (let ((props-r '((diff-mode . fine) (face . diff-refine-removed)))
          (props-a '((diff-mode . fine) (face . diff-refine-added))))
      (remove-overlays beg end 'diff-mode 'fine)
      (goto-char beg)
      (while (re-search-forward "^-" end t)
        (beginning-of-line)
        (let ((dels (my/magit-diff--collect-lines ?- end))
              (adds (my/magit-diff--collect-lines ?+ end)))
          (while (and dels adds)
            (let ((del (pop dels))
                  (add (pop adds)))
              (when (my/magit-diff--lines-similar-p del add)
                (smerge-refine-regions (car del) (cdr del) (car add) (cdr add)
                                       nil #'diff-refine-preproc
                                       props-r props-a))))))))

  (defun my/magit-diff-refine-line-pairs (fn beg end)
    (if (derived-mode-p 'magit-mode)
        (my/magit-diff--refine-line-pairs beg end)
      (funcall fn beg end)))
  (advice-add 'diff--refine-hunk :around #'my/magit-diff-refine-line-pairs))

;;;;; Diffstat tree
;; Group the files in a diffstat under collapsible directory sections.
(use-package magit-diffstat-tree
  :ensure nil
  :after magit
  :config
  (magit-diffstat-tree-mode 1))

;;;; Magit: bare-repo dotfiles
(use-package magit
  :ensure nil
  :config
  (defun my/magit-process-environment (env)
    "Detect and set git -bare repo env vars when in tracked dotfile directories."
    (let* ((default (file-name-as-directory (expand-file-name default-directory)))
           (git-dir (expand-file-name "~/.cfg"))
           (work-tree (expand-file-name "~/"))
           (dotfile-dirs
            (-map (apply-partially 'concat work-tree)
                  (-uniq (-keep #'file-name-directory (split-string (shell-command-to-string
                                                                     (format "/usr/bin/git --git-dir=%s --work-tree=%s ls-tree --full-tree --name-only -r HEAD"
                                                                             git-dir work-tree))))))))
      (push work-tree dotfile-dirs)
      (when (member default dotfile-dirs)
        (push (format "GIT_WORK_TREE=%s" work-tree) env)
        (push (format "GIT_DIR=%s" git-dir) env)))
    env)
  (advice-add 'magit-process-environment
              :filter-return #'my/magit-process-environment))

;;;; Magit: open the file at point in Eclipse
(use-package magit
  :ensure nil
  :config
  (defun my/magit-open-file-in-eclipse ()
    "Open the file under the cursor in Eclipse, jumping to the current line when point is on a diff hunk."
    (interactive)
    (let* ((repo-path (magit-repository-local-repository))
           (file (magit-current-file))
           (had-buffer (get-file-buffer (expand-file-name file repo-path)))
           (line (and (magit-section-match 'hunk)
                      (ignore-errors
                        (pcase-let ((`(,buf ,pos) (magit-diff-visit-file--noselect t)))
                          (prog1 (with-current-buffer buf (line-number-at-pos pos))
                            (unless had-buffer (kill-buffer buf)))))))
           (command (format "%s../../eclipse/eclipse --launcher.openFile %s%s%s"
                            repo-path repo-path file
                            (if line (format ":%d" line) ""))))
      (start-process-shell-command "eclipse-launcher" nil command)))
  (with-eval-after-load 'evil-collection-magit
    (evil-define-key 'normal magit-mode-map (kbd "gf") 'my/magit-open-file-in-eclipse)
    ;; In the status buffer `gf' is a prefix (gfu/gfp jump to unpulled commits),
    ;; which shadows the binding above
    (evil-define-key 'normal magit-status-mode-map
      (kbd "gf") 'my/magit-open-file-in-eclipse)
    (evil-define-key 'normal magit-process-mode-map (kbd "gx") 'browse-url-at-point)))

;;;; Keychain
(use-package keychain-environment
  :ensure t
  :hook (after-init . keychain-refresh-environment))

;;; Org
(use-package org
  :ensure nil
  :config
  ;; When a TODO is set to a done state, record a timestamp
  (setq org-log-done 'time)
  (setq org-return-follows-link t)
  (setq org-hide-emphasis-markers t)
  (add-hook 'org-mode-hook 'org-indent-mode)  ; nicer indentation
  (add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))
  (add-hook 'org-mode-hook 'variable-pitch-mode) ; proportionally spaced font

  (font-lock-add-keywords
   'org-mode
   '(("^ *\\([-]\\) " (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))    ; Substitute list markers ("-" -> "•")
     ("^\\**\\(*\\) " (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "⁕"))))))  ; Substitute header markers ("*" -> "⁕")

  (defun my/org-setup-faces (&optional _frame)
    (let ((mono-spaced-font "IBM Plex Mono")
          (proportionately-spaced-font "IBM Plex Serif")
          (background-color    (face-background 'default nil 'default)))
      (dolist (face '((org-level-1 . 1.25)
                      (org-level-2 . 1.2)
                      (org-level-3 . 1.15)
                      (org-level-4 . 1.1)
                      (org-level-5 . 1.1)
                      (org-level-6 . 1.1)
                      (org-level-7 . 1.1)
                      (org-level-8 . 1.1)))
        ;; box is a hack to get more line spacing for headlines
        (set-face-attribute (car face) nil :font proportionately-spaced-font :height (cdr face) :box `(:line-width (1 . 4) :color ,background-color)))
      (set-face-attribute 'org-level-1 nil          :weight 'bold)
      (set-face-attribute 'org-document-title nil   :font proportionately-spaced-font :weight 'bold :height 1.3)
      (set-face-attribute 'org-block nil            :inherit 'fixed-pitch :height 0.9)
      (set-face-attribute 'org-block-begin-line nil :inherit '(font-lock-comment-face fixed-pitch) :height 0.9)
      (set-face-attribute 'org-table nil            :font mono-spaced-font :height 0.9)
      (set-face-attribute 'org-formula nil          :font mono-spaced-font :height 0.9)
      (set-face-attribute 'org-code nil             :font mono-spaced-font)
      (set-face-attribute 'org-verbatim nil         :font mono-spaced-font)
      (set-face-attribute 'org-checkbox nil         :font mono-spaced-font)
      (set-face-attribute 'org-special-keyword nil  :inherit '(font-lock-comment-face fixed-pitch))
      (set-face-attribute 'org-meta-line nil        :inherit '(font-lock-comment-face fixed-pitch))))

  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'my/org-setup-faces)
    (my/org-setup-faces))

  (org-babel-do-load-languages
   'org-babel-load-languages '((shell . t))))

(use-package org-appear
  :ensure t
  :commands (org-appear-mode)
  :hook     (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis   t   ; Show bold, italics, verbatim, etc.
        org-appear-autolinks      t   ; Show links
        org-appear-autosubmarkers t)) ; Show sub- and superscripts

;;; LSP
(use-package eglot
  :ensure nil
  :config
  ;; use 'c' as a prefix key for keybinds staring with cr, while remaining an operator otherwise
  (defmacro my/evil-change-command (func)
    `(lambda ()
       (interactive)
       (when (eq evil-this-operator 'evil-change)
         (call-interactively ,func))))
  (evil-define-key 'operator 'evil-normal-state-map
    "rn" (my/evil-change-command #'eglot-rename)
    "ra" (my/evil-change-command #'eglot-code-actions)
    "rf" (my/evil-change-command #'eglot-format)
    "ro" (my/evil-change-command #'eglot-code-action-organize-imports))
  (set-face-attribute 'eglot-highlight-symbol-face nil :weight 'normal))

(use-package flycheck
  :ensure t
  :config
  (advice-add 'flycheck-eslint-config-exists-p :override #'always))

(defun my/flycheck-use-local-eslint ()
  (when-let* ((root (locate-dominating-file buffer-file-name "node_modules"))
              (eslint (expand-file-name "node_modules/.bin/eslint" root)))
    (when (file-executable-p eslint)
      (setq-local flycheck-javascript-eslint-executable eslint))))

(add-hook 'flycheck-mode-hook #'my/flycheck-use-local-eslint)

(use-package apheleia
  :ensure t
  :hook (after-init . apheleia-global-mode))

;;; Debugger (DAP)
(use-package dape
  :ensure t
  :config
  (set-face-attribute 'dape-source-line-face nil
                      :background (modus-themes-get-color-value 'bg-yellow-subtle)
                      :extend t)

  (transient-define-prefix my/dape-transient ()
    [:hide always
           ("q"        "close menu" transient-quit-one)
           ("<escape>" "close menu" transient-quit-one)]
    [["Session"
      ("d" "start"      dape)
      ("r" "restart"    dape-restart)
      ("D" "detach"     dape-disconnect-quit)
      ("K" "kill"       dape-kill)
      ("Q" "quit all"   dape-quit)]
     ["Step"
      ("c" "continue"   dape-continue)
      ("n" "next"       dape-next              :transient t)
      ("s" "step in"    dape-step-in           :transient t)
      ("o" "step out"   dape-step-out          :transient t)
      ("u" "until"      dape-until)
      ("p" "pause"      dape-pause)]
     ["Breakpoints"
      ("b" "toggle"     dape-breakpoint-toggle)
      ("e" "expression" dape-breakpoint-expression)
      ("l" "log"        dape-breakpoint-log)
      ("h" "hits"       dape-breakpoint-hits)
      ("F" "function"   dape-breakpoint-function)
      ("B" "remove all" dape-breakpoint-remove-all)]
     ["Inspect"
      ("i" "info"       dape-info)
      ("R" "repl"       dape-repl)
      ("x" "eval"       dape-evaluate-expression)
      ("w" "watch"      dape-watch-dwim)
      ("S" "stack"      dape-select-stack)
      ("t" "thread"     dape-select-thread)
      ("<" "frame up"   dape-stack-select-up   :transient t)
      (">" "frame down" dape-stack-select-down :transient t)]])

  (define-key evil-normal-state-map (kbd "SPC") #'my/dape-transient)

  (keymap-global-set "<f9>"  #'dape-breakpoint-toggle)
  (keymap-global-set "<f10>" #'dape-next)
  (keymap-global-set "<f11>" #'dape-step-in)
  (keymap-global-set "<f12>" #'dape-step-out)

  (defun my/dape-start-or-continue ()
    "Resume a stopped session, or launch/attach the dev host when there is none."
    (interactive)
    (cond ((dape--live-connection 'stopped 'nowarn)
           (call-interactively #'dape-continue))
          ((dape--live-connection 'parent 'nowarn)
           (message "Extension host is running; nothing to resume"))
          (t (my/vscode-dev-host-debug))))

  (keymap-global-set "<f5>" #'my/dape-start-or-continue))

;;;; Dape: Sigasi VS Code extension host
(use-package dape
  :ensure nil
  :config
  (add-to-list 'dape-configs
               `(sigasi-extension
                 modes nil
                 ensure (lambda (_)
                          (let ((adapter (expand-file-name "js-debug/src/dapDebugServer.js" dape-adapter-dir)))
                            (unless (file-exists-p adapter)
                              (user-error "js-debug not found"))))
                 command "node"
                 command-args (,(expand-file-name "js-debug/src/dapDebugServer.js" dape-adapter-dir) :autoport)
                 port :autoport
                 :type "pwa-node"
                 :request "attach"
                 ;; Only the port the dev host is asked for; `my/vscode-dev-host-debug'
                 ;; overrides it with the one the extension host really listens on.
                 :port 9229
                 :cwd dape-cwd-fn
                 :restart t
                 :continueOnAttach t
                 :sourceMaps t
                 :resolveSourceMapLocations ["${workspaceFolder}/**" "!**/node_modules/**"])))

;;;; Dape: launch the dev host
(use-package dape
  :ensure nil
  :config
  (require 'filenotify)

  (defvar my/vscode-dev-host-program "sigasi-dev-host"
    "Script that builds the extension, runs the dev host and publishes its port.")

  (defvar my/vscode-dev-host-port-file
    (expand-file-name "sigasi-dev-host.port"
                      (or (getenv "XDG_RUNTIME_DIR") temporary-file-directory))
    "File the script publishes the port to; its $SIGASI_DEV_HOST_PORT_FILE.")

  (defvar my/vscode-dev-host--process nil "The dev host we started, if any.")
  (defvar my/vscode-dev-host--watch nil "Watch descriptor for the port file.")
  (defvar my/vscode-dev-host--port nil "Port dape was last attached to.")

  (defun my/vscode-dev-host--published-port ()
    "Return the port in `my/vscode-dev-host-port-file', or nil.
The script writes it once the inspector accepts connections and removes it
again when the extension host exits."
    (when (file-readable-p my/vscode-dev-host-port-file)
      (with-temp-buffer
        (insert-file-contents my/vscode-dev-host-port-file)
        (goto-char (point-min))
        (when (re-search-forward "[0-9]+" nil t)
          (string-to-number (match-string 0))))))

  (defun my/vscode-dev-host--attach (port)
    "Attach dape to the extension host on PORT, replacing any live session."
    (setq my/vscode-dev-host--port port)
    (let ((config (dape--config-eval 'sigasi-extension (list :port port))))
      (if-let* ((conn (dape--live-connection 'parent 'nowarn)))
          (dape-kill conn (lambda (&rest _) (dape config)))
        (dape config))))

  (defun my/vscode-dev-host--port-changed (event)
    "Attach to, or forget, the port EVENT says the script published."
    (let ((file (or (nth 3 event) (nth 2 event))))
      (when (equal (file-name-nondirectory file)
                   (file-name-nondirectory my/vscode-dev-host-port-file))
        (let ((port (my/vscode-dev-host--published-port)))
          (cond ((null port)
                 (when my/vscode-dev-host--port
                   (setq my/vscode-dev-host--port nil)
                   (message "Extension host exited; waiting for its replacement")))
                ((not (eql port my/vscode-dev-host--port))
                 (message "Attaching dape to the extension host on port %d" port)
                 (my/vscode-dev-host--attach port)))))))

  (defun my/vscode-dev-host--follow ()
    "Watch the port file, so a reload is followed to its new port."
    (unless my/vscode-dev-host--watch
      (setq my/vscode-dev-host--watch
            (file-notify-add-watch
             (file-name-directory my/vscode-dev-host-port-file)
             '(change) #'my/vscode-dev-host--port-changed))))

  (defun my/vscode-dev-host--unfollow ()
    "Stop watching the port file."
    (when my/vscode-dev-host--watch
      (file-notify-rm-watch my/vscode-dev-host--watch)
      (setq my/vscode-dev-host--watch nil)))

  (defun my/vscode-dev-host--sentinel (proc event)
    "Forget the dev host PROC once EVENT says it is gone."
    (unless (process-live-p proc)
      (setq my/vscode-dev-host--process nil
            my/vscode-dev-host--port nil)
      (my/vscode-dev-host--unfollow)
      (message "Sigasi dev host exited (%s)" (string-trim event))))

  (defun my/vscode-dev-host--launch ()
    "Run the dev host script, collecting its output in `*sigasi-dev-host*'."
    (let ((program (or (executable-find my/vscode-dev-host-program)
                       (user-error "%s not found on PATH"
                                   my/vscode-dev-host-program)))
          (buffer (get-buffer-create "*sigasi-dev-host*")))
      (with-current-buffer buffer (erase-buffer))
      (setq my/vscode-dev-host--port nil
            my/vscode-dev-host--process
            (make-process
             :name "sigasi-dev-host"
             :buffer buffer
             :noquery t
             :connection-type 'pipe
             :command (list program)
             :sentinel #'my/vscode-dev-host--sentinel))))

  (defun my/vscode-dev-host-debug ()
    "Debug the Sigasi extension.
With a dev host already up, attach to the port it published; with nothing running,
start the script."
    (interactive)
    (my/vscode-dev-host--follow)
    (let ((port (my/vscode-dev-host--published-port)))
      (cond (port (my/vscode-dev-host--attach port))
            ((process-live-p my/vscode-dev-host--process)
             (message "Sigasi dev host is still starting; see *sigasi-dev-host*"))
            (t (my/vscode-dev-host--launch)
               (message "Started the Sigasi dev host; waiting for its port"))))))

;;; Language specific
(use-package sly
  :ensure nil
  :config
  (setq sly-mrepl-history-file-name "/home/vital/.local/state/sly-mrepl-history")
  (setq inferior-lisp-program "sbcl"))

(defun lisp-word-syntax ()
  (modify-syntax-entry ?- "w")
  (modify-syntax-entry ?/ "w"))
(dolist (hook '(emacs-lisp-mode-hook lisp-mode-hook))
  (add-hook hook 'lisp-word-syntax))

(defun my/emacs-lisp-outline ()
  "Enable outline folding, starting folded to the top-level headings."
  (setq-local outline-regexp ";;;;* [^ \t\n]")
  (outline-minor-mode 1)
  (outline-hide-sublevels 1)
  ;; `outline-cycle-buffer' tracks visibility itself, and still reads
  ;; `show-all' after the fold above -- which makes the first S-TAB a no-op
  ;; that merely refolds.
  (setq outline--cycle-buffer-state 'top-level))
(add-hook 'emacs-lisp-mode-hook #'my/emacs-lisp-outline)

(defun c-word-syntax ()
  (modify-syntax-entry ?_ "w"))
(dolist (hook '(c-mode-hook c++-mode-hook))
  (add-hook hook 'c-word-syntax))

(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
             "master" "tsx/src")))

(dolist (lang treesit-language-source-alist)
  (unless (treesit-language-available-p (car lang))
    (treesit-install-language-grammar (car lang))))

(use-package typescript-ts-mode
  :ensure nil
  :config
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (setq typescript-ts-mode-indent-offset 4)
  :hook (typescript-ts-mode . (lambda ()
                                (eglot-ensure)
                                (flycheck-mode 1))))

(custom-set-variables
 '(markdown-command "/usr/bin/pandoc"))
