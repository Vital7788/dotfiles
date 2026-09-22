;; -*- lexical-binding: t; -*-
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;;; Set up package manager

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq package-install-upgrade-built-in t)

;; Local packages, not installed through `package'
(add-to-list 'load-path (locate-user-emacs-file "lisp"))

;;; Basic behavior

(defun my/reload-init ()
  (interactive)
  (load user-init-file))

(setq inhibit-startup-screen t)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.local/state/emacs/
(setq backup-directory-alist '(("." . "~/.local/state/emacs/backup")))
(setq auto-save-file-name-transforms '((".*" "~/.local/state/emacs/autosave/\\1" t)))
(make-directory "~/.local/state/emacs/autosave/" t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; Adopt the indentation actually used by the visited file (tabs vs spaces, and
;; the offset), falling back to the defaults above when there is none to detect.
(use-package dtrt-indent
  :ensure t
  :hook (after-init . dtrt-indent-global-mode))

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

;; Emacs 30 and newer: Disable Ispell completion function.
;; Try `cape-dict' as an alternative.
;; (setq text-mode-ispell-word-completion nil)

;; Hide commands in M-x which do not apply to the current mode.
(setq read-extended-command-predicate #'command-completion-default-include-p)

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

;;; Buffer Display
(setq display-buffer-alist
      '(("^\\*eldoc"
         display-buffer-at-bottom
         (window-height . 0.2))
        ("^\\*Help\\*$"
         nil
         (window-height . 0.35)
         (window-width . 80)
         (preserve-size . (t nil)))
        ;; Don't show byte compilation warnings after installing packages
        ("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
         display-buffer-no-window
         (allow-no-window . t))))

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
  (evil-global-set-key 'normal (kbd ",r") 'my/reload-init)

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

  ;; add preview to consult-fd
  (consult-customize consult-fd :state (consult--file-preview))
  ;; add preview to hidden buffers
  (consult-customize consult-source-hidden-buffer :state #'consult--buffer-state)

  (setq consult-buffer-list-function #'consult--frame-buffer-list)
  ;; Start fresh emacsclient with empty buffer list
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (set-frame-parameter nil 'buffer-list nil)
              (set-frame-parameter nil 'buried-buffer-list nil)))

  (add-to-list 'consult-buffer-filter "\\`\\*.*\\*\\'")
  (add-to-list 'consult-buffer-filter "\\`magit-process: ")

  (defun my/git-dir (dir)
    "Path of DIR's git directory, or nil if it has none."
    (let ((dotgit (expand-file-name ".git" dir)))
      (cond ((file-directory-p dotgit) dotgit)
            ((file-regular-p dotgit)     ; worktree or submodule
             (with-temp-buffer
               (insert-file-contents dotgit)
               (when (looking-at "gitdir: \\(.*\\)")
                 (expand-file-name (match-string 1) dir))))
            ;; The dotfiles work tree is ~/, its git dir is the bare ~/.cfg
            ((file-equal-p dir "~/") (expand-file-name "~/.cfg")))))

  (defun my/git-reflog-activity (gitdir)
    "Recent activity of the repository at GITDIR.
Returns (COUNT . LAST-TIME), COUNT being the number of HEAD reflog entries
within the last two weeks."
    (let ((log (expand-file-name "logs/HEAD" gitdir))
          ;; cutoff of 2 weeks
          (cutoff (- (time-convert nil 'integer) (* 14 24 60 60)))
          (count 0)
          (last 0))
      (when (file-readable-p log)
        (with-temp-buffer
          (let ((size (file-attribute-size (file-attributes log))))
            ;; Only the tail can fall inside the window; 64K is ~350 entries.
            (insert-file-contents-literally log nil (max 0 (- size 65536)) size))
          (goto-char (point-min))
          ;; Author names contain spaces, so anchor on the end of the email.
          (while (re-search-forward "> \\([0-9]+\\) [-+][0-9]+\t" nil t)
            (let ((time (string-to-number (match-string 1))))
              (setq last (max last time))
              (when (> time cutoff) (setq count (1+ count)))))))
      (cons count last)))

  (defun my/consult-git-repos-scan ()
    "Get git repositories from bookmarks, most active first."
    (bookmark-maybe-load-default-file)
    (let ((bookmarks (cons (cons "dotfiles" (expand-file-name "~/"))
                           (mapcar (lambda (name)
                                     (cons name (bookmark-get-filename name)))
                                   (bookmark-all-names))))
          scored)
      (pcase-dolist (`(,name . ,dir) bookmarks)
        (when-let* ((gitdir (and dir (my/git-dir dir))))
          (push (cons (cons name dir) (my/git-reflog-activity gitdir)) scored)))
      (mapcar #'car
              (sort (nreverse scored)
                    :lessp (lambda (a b)
                             (let ((a (cdr a)) (b (cdr b)))
                               (or (> (car a) (car b))
                                   (and (= (car a) (car b))
                                        (> (cdr a) (cdr b))))))))))

  (defvar my/consult-git-repos-cache (my/consult-git-repos-scan)
    "Alist of (BOOKMARK-NAME . DIR), most active repository first.")

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
  (setq corfu-cycle t)
  (defun my/corfu-tab ()
    "Expand the common prefix of the candidates, else go to the next one."
    (interactive)
    (or (corfu-expand) (corfu-next)))
  (keymap-set corfu-map "TAB" #'my/corfu-tab)
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
  (defun my/glab-mr-target-branch (branch)
    "Target branch of BRANCH's merge request, or nil when it has none."
    (with-temp-buffer
      (and (zerop (process-file "glab" nil t nil
                                "mr" "view" branch "--output" "json"))
           (progn
             (goto-char (point-min))
             (ignore-errors
               (alist-get 'target_branch
                          (json-parse-buffer :object-type 'alist)))))))

  (defun my/magit-diff-base-branch ()
    "Branch the current one is meant to be merged into."
    (let* ((branch (or (magit-get-current-branch)
                       ;; Get branch name for detached HEAD
                       (car (seq-remove
                             (lambda (ref) (equal ref "HEAD"))
                             (magit-git-lines "for-each-ref"
                                              "--format=%(refname:lstrip=3)"
                                              "--points-at=HEAD"
                                              "refs/remotes/origin")))))
           (target (and branch
                        (executable-find "glab")
                        (my/glab-mr-target-branch branch))))
      (or (and target (concat "origin/" target))
          (magit-git-string "symbolic-ref" "--short"
                            "refs/remotes/origin/HEAD")
          "origin/master")))

  (defun my/magit-diff-merge-request-base (&optional args files)
    "Diff the current branch against the branch its merge request targets."
    (interactive (magit-diff-arguments))
    (let ((base (my/magit-diff-base-branch)))
      (message "Diffing against %s" base)
      (magit-diff-setup-buffer (concat base "...") nil args files 'committed)))
  (transient-append-suffix 'magit-diff "r"
    '("o" "Diff merge-request base..." my/magit-diff-merge-request-base)))

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
;; Magit gives every hunk its own section and paints each one, so a
;; file with many hunks takes too long to render. Past the first
;; threshold below such a file loses its word-level diffs and syntax
;; highlighting; past the second its hunks are merged into one
;; section, which stays a valid patch but can no longer be staged hunk
;; by hunk.
(use-package magit
  :ensure nil
  :config
  (require 'cl-lib)

  (setq magit-diff-refine-hunk 'all)
  (setq magit-diff-fontify-hunk 'all)

  (defvar my/magit-diff-detail-threshold 15
    "Refine and fontify a file's hunks only when it has at most this many.")

  (defvar my/magit-diff-merge-threshold 100
    "Merge a file's hunks into one section once it has more than this many.")

  (defconst my/magit-diff-hunk-re "^@\\{2,\\}")

  (defconst my/magit-diff-file-re
    (concat "^\\(diff\\|Submodule\\|\\* Unmerged path\\|"
            (substring magit-diff-conflict-headline-re 1)
            "\\)")
    "Like `magit-diff-headline-re', but does not match a hunk headline.")

  (defun my/magit-diff-annotate-merged (content count face)
    "Show in FACE that the heading ending at CONTENT stands for COUNT hunks.
A `display' property, so the section's text stays the patch given to git."
    (put-text-property
     (1- content) content 'display
     (concat (propertize (format " (%d hunks, whole file)" count) 'face face)
             "\n")))

  (defun my/magit-diff-wash-merged (end count)
    "Put every hunk up to END into one section, COUNT hunks in total."
    (when (looking-at "^@\\{2,\\} \\(.+?\\) @\\{2,\\}\\(?: \\(.*\\)\\)?")
      (let* ((heading (match-string-no-properties 0))
             (ranges (mapcar
                      (lambda (str)
                        (let ((range (mapcar #'string-to-number
                                             (split-string (substring str 1) ","))))
                          ;; A single line is +1 rather than +1,1.
                          (if (length= range 1) (nconc range (list 1)) range)))
                      (split-string (match-string-no-properties 1))))
             (about (match-string-no-properties 2))
             (combined (length= ranges 3)))
        (magit-delete-line)
        (magit-insert-section
            ( hunk (cons about ranges) nil
              :combined combined
              :from-range (if combined (butlast ranges) (car ranges))
              :to-range (car (last ranges))
              :about about)
          ;; Magit reads these slots to skip work it has already done.
          (oset magit-insert-section--current refined t)
          (oset magit-insert-section--current fontified t)
          (magit-insert-heading
            (propertize (concat heading "\n")
                        'font-lock-face 'magit-diff-hunk-heading))
          (my/magit-diff-annotate-merged (point) count 'magit-diff-hunk-heading)
          (goto-char end))))
    nil)                                ; stop `magit-wash-sequence'

  (defun my/magit-diff-limit-large-file (fn &rest args)
    "Wash the hunks of a file that has very many of them more cheaply."
    (let* ((end (and (looking-at my/magit-diff-hunk-re)
                     (save-excursion
                       ;; Washing is narrowed to one git call, so `point-max'
                       ;; ends the last file.
                       (if (re-search-forward my/magit-diff-file-re nil t)
                           (line-beginning-position)
                         (point-max)))))
           (count (and end (how-many my/magit-diff-hunk-re (point) end))))
      (cond
       ((not (and count (> count my/magit-diff-detail-threshold)))
        (apply fn args))
       ((<= count my/magit-diff-merge-threshold)
        (let ((section (apply fn args)))
          (dolist (hunk (oref section children))
            (oset hunk refined t)
            (oset hunk fontified t))
          section))
       (t
        ;; A marker: the heading is deleted and reinserted before we get there.
        (let ((end (copy-marker end)))
          (unwind-protect
              (cl-letf (((symbol-function 'magit-diff-wash-hunk)
                         (lambda () (my/magit-diff-wash-merged end count))))
                (apply fn args))
            (set-marker end nil)))))))
  (advice-add 'magit-diff-insert-file-section :around
              #'my/magit-diff-limit-large-file)

  (cl-defmethod magit-section-paint :after ((section magit-hunk-section) highlight)
    "Face the merged-in headings of SECTION, which magit paints as context.
A no-op for magit's own hunk sections, whose bodies hold no \"@@\" line."
    (when-let ((beg (oref section content))
               (end (oref section end))
               (face (if highlight
                         'magit-diff-hunk-heading-highlight
                       'magit-diff-hunk-heading)))
      (save-excursion
        (goto-char beg)
        (let ((count 1))
          (while (re-search-forward my/magit-diff-hunk-re end t)
            (cl-incf count)
            (put-text-property (match-beginning 0)
                               (min end (1+ (line-end-position)))
                               'font-lock-face face))
          (when (> count 1)
            (my/magit-diff-annotate-merged beg count face))))))

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
;;;; Snippets
(use-package yasnippet
  :ensure t
  :defer t)

;;;; Eglot
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

;;;; Eldoc
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(use-package eldoc-box
  :ensure t
  :config
  (defun my/eldoc-box-signature (docs _interactive)
    "Show the signature help while in insert mode."
    (if-let* (((evil-insert-state-p))
              (doc (seq-find (lambda (doc)
                               (eq (plist-get (cdr doc) :origin)
                                   'eglot-signature-eldoc-function))
                             docs)))
        (eldoc-box--display (car doc))
      (eldoc-box-quit-frame)))

  (defun my/eldoc-box-signature-setup ()
    "Display signature help beside point for as long as eglot manages this buffer."
    (cond
     ((eglot-managed-p)
      (setq-local eldoc-box-position-function eldoc-box-at-point-position-function)
      (add-hook 'eldoc-display-functions #'my/eldoc-box-signature nil t)
      (add-hook 'post-command-hook #'eldoc-box--follow-cursor nil t))
     (t
      (remove-hook 'eldoc-display-functions #'my/eldoc-box-signature t)
      (remove-hook 'post-command-hook #'eldoc-box--follow-cursor t))))
  (add-hook 'eglot-managed-mode-hook #'my/eldoc-box-signature-setup)
  (add-hook 'evil-insert-state-exit-hook #'eldoc-box-quit-frame))

;;;; Flymake
(use-package flymake
  :ensure nil
  :config
  ;; Project-wide diagnostics
  (define-key evil-normal-state-map (kbd ",d") 'flymake-show-project-diagnostics)
  ;; Buffer diagnostics
  (define-key evil-normal-state-map (kbd ",D") 'flymake-show-buffer-diagnostics))

;;;;; ESLint
(use-package flymake-eslint
  :ensure t
  :config
  ;; `flymake-eslint-enable' would otherwise refuse to set up a buffer whose
  ;; project has no eslint binary yet, e.g. before `yarn install'.
  (setq flymake-eslint-defer-binary-check t)

  (defun my/flymake-eslint-enable ()
    "Lint the current buffer with its own project's eslint.
Runs from `eglot-managed-mode-hook' rather than from the major mode hook
because eglot replaces `flymake-diagnostic-functions' wholesale when it
takes a buffer over, which drops any backend registered before it."
    (when (and (eglot-managed-p)
               (derived-mode-p 'typescript-ts-base-mode))
      (when-let* ((root (locate-dominating-file default-directory "node_modules")))
        (setq-local flymake-eslint-executable-name
                    (expand-file-name "node_modules/.bin/eslint" root)))
      (flymake-eslint-enable)))

  (add-hook 'eglot-managed-mode-hook #'my/flymake-eslint-enable))

;;;;; Project-wide TypeScript diagnostics
(use-package flymake
  :ensure nil
  :commands flymake-show-project-diagnostics
  :config
  (defvar my/tsc-problems--files nil
    "Files the last refresh added to `flymake-list-only-diagnostics'.")

  (defun my/tsc-problems--parse ()
    "Read problems into an alist of (FILE . DIAGNOSTICS)."
    (with-temp-buffer
      (apply #'process-file "sigasi-dev" nil t nil '("ext" "problems"))
      (goto-char (point-min))
      (let (by-file)
        (while (not (eobp))
          (when (looking-at (concat "\\([^\t\n]+\\)\t\\([^\t\n]+\\)\t"
                                    "\\([0-9]+\\)\t\\([0-9]+\\)\t"
                                    "\\([^\t\n]+\\)\t\\(.*\\)"))
            (let ((file (match-string 2)))
              (push (flymake-make-diagnostic
                     file
                     (cons (string-to-number (match-string 3))
                           (string-to-number (match-string 4)))
                     nil
                     (pcase (match-string 1)
                       ("error" :error)
                       ("warning" :warning)
                       (_ :note))
                     (format "%s: %s" (match-string 5) (match-string 6)))
                    (alist-get file by-file nil nil #'equal))))
          (forward-line 1))
        by-file)))

  (defun my/tsc-problems-refresh (&rest _)
    "Put the watcher's problems in `flymake-list-only-diagnostics'.
Replaces the batch of the previous refresh.  Entries are keyed by file,
the same way eglot keys the ones it reports for files it has not opened,
so the two can coexist in that variable."
    (let ((by-file (my/tsc-problems--parse)))
      (dolist (file (append my/tsc-problems--files (mapcar #'car by-file)))
        (setq flymake-list-only-diagnostics
              (assoc-delete-all file flymake-list-only-diagnostics)))
      (setq my/tsc-problems--files (mapcar #'car by-file))
      (pcase-dolist (`(,file . ,diags) by-file)
        (push (cons file (nreverse diags)) flymake-list-only-diagnostics))))

  ;; `flymake-show-project-diagnostics' goes through this function, so the list
  ;; is up to date whenever it is shown or reverted.
  (advice-add 'flymake--project-diagnostics :before #'my/tsc-problems-refresh))

;;;; Apheleia
(use-package apheleia
  :ensure t
  :hook (after-init . apheleia-global-mode)
  :config
  ;; match VS Code behavior
  (add-to-list 'apheleia-mode-alist
               '("/package\\(-lock\\)?\\.json\\'" . prettier-json-stringify)))

;;;; IntelliJ LSP
;; Java/Kotlin via JetBrains' IntelliJ language server (see lisp/intellij-eglot.el).
;; The server is an EAP preview and expires 30 days after its build date.
(use-package intellij-eglot
  :ensure nil
  :hook (java-mode . my/java-eglot-ensure)
  :init
  (defun my/java-eglot-ensure ()
    "Register the IntelliJ server with eglot, then manage this buffer."
    (require 'intellij-eglot)
    (intellij-server-ensure)))

(use-package jarchive
  :ensure t
  :hook (after-init . jarchive-mode))

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

  (defun my/dape-start-or-continue ()
    "Resume a stopped session, or start the one this buffer's mode calls for."
    (interactive)
    (cond ((dape--live-connection 'stopped 'nowarn)
           (call-interactively #'dape-continue))
          ((dape--live-connection 'parent 'nowarn)
           (message "A debug session is already running; nothing to resume"))
          ((derived-mode-p 'typescript-ts-base-mode 'tsx-ts-mode 'js-ts-mode)
           (my/vscode-inspect))
          ((derived-mode-p 'java-mode 'java-ts-mode)
           (dape (dape--config-eval 'sigasi-lsp-server nil)))
          (t (call-interactively #'dape))))

  (keymap-global-set "<f5>"  #'my/dape-start-or-continue)
  (keymap-global-set "<f9>"  #'dape-breakpoint-toggle)
  (keymap-global-set "<f10>" #'dape-next)
  (keymap-global-set "<f11>" #'dape-step-in)
  (keymap-global-set "<f12>" #'dape-step-out))

;;;; Dape: VS Code extension host
(use-package dape
  :ensure nil
  :config
  (defun my/vscode-extension-path ()
    (bookmark-maybe-load-default-file)
    (file-name-as-directory
     (expand-file-name (or (bookmark-get-filename "vscode")
                           (user-error "No \"vscode\" bookmark")))))

  (defvar my/vscode-inspect-port 9229)

  (defun my/vscode-inspect ()
    (make-process
     :name "vscode-inspect"
     :command '("sigasi-dev" "start" "--debug" "--follow")
     :connection-type 'pipe
     :filter #'my/vscode-inspect-filter))

  (defun my/vscode-inspect-filter (proc string)
    "Restart Dape when a new port gets published"
    (if (string-equal string "port none\n")
        (progn
          (message "stopping VS Code inspector")
          (interrupt-process proc))
      (let ((port (string-to-number string)))
        (when (not (zerop port))
          (setq my/vscode-inspect-port port)
          (dape--kill-busy-wait)
          (message (concat "reloading dape with port " string))
          (dape (dape--config-eval 'sigasi-extension nil))))))

  (defun my/js-debug-adapter ()
    "Get config from dape's `js-debug-node'."
    (let ((config (alist-get 'js-debug-node dape-configs)))
      (mapcan (lambda (key) (list key (plist-get config key)))
              '(ensure command command-args port))))

  (add-to-list 'dape-configs
               `(sigasi-extension
                 ,@(my/js-debug-adapter)
                 modes (typescript-ts-mode tsx-ts-mode js-ts-mode)
                 :type "pwa-extensionHost"
                 :request "attach"
                 :port my/vscode-inspect-port
                 :cwd my/vscode-extension-path
                 :__workspaceFolder (directory-file-name (my/vscode-extension-path))
                 :sourceMaps t
                 :outFiles ["${workspaceFolder}/app/**/*.js"]
                 :resolveSourceMapLocations ["${workspaceFolder}/**"
                                             "!**/node_modules/**"
                                             "!**/.vscode-test/**"])))

;;;; Dape: VS Code extension tests
(use-package dape
  :ensure nil
  :config
  (defvar my/vscode-test-callers '("suite" "test" "describe" "it")
    "Mocha functions whose first argument titles a suite or a test.")

  (defun my/vscode-test-title ()
    "Mocha's full title for the test around point."
    (let ((node (treesit-node-at (point)))
          titles innermost)
      (while node
        (when-let* (((equal (treesit-node-type node) "call_expression"))
                    (caller (treesit-node-child-by-field-name node "function"))
                    ((member (treesit-node-text caller) my/vscode-test-callers))
                    (args (treesit-node-child-by-field-name node "arguments"))
                    (string (treesit-node-child args 0 t))
                    (title (treesit-node-child string 0 t)))
          (push (treesit-node-text title) titles)
          (unless innermost (setq innermost (treesit-node-text caller))))
        (setq node (treesit-node-parent node)))
      (if (member innermost '("test" "it"))
          (string-join titles " ")
        "")))

  (defun my/vscode-test-compile (&rest options)
    "Run the test around point in a compilation buffer, with OPTIONS."
    (let ((default-directory (my/vscode-extension-path)))
      (compilation-start (mapconcat #'shell-quote-argument
                                    `("sigasi-dev" "ext" "test" ,@options
                                      ,buffer-file-name ,(my/vscode-test-title))
                                    " ")
                         #'my/vscode-test-mode)))

  (defun my/vscode-test ()
    "Run the test around point."
    (interactive)
    (my/vscode-test-compile))

  (defun my/vscode-test-debug ()
    "Debug the test around point."
    (interactive)
    (my/vscode-test-compile "--debug"))

  (defun my/vscode-test-attach ()
    "Attach to a run once it announces the port its extension host opened."
    (save-excursion
      (goto-char compilation-filter-start)
      (forward-line 0)
      (when (re-search-forward "^inspect-port \\([0-9]+\\)$" nil t)
        (setq my/vscode-inspect-port (string-to-number (match-string 1)))
        (dape (dape--config-eval 'sigasi-extension nil)))))

  ;; Mocha reports a stack frame as `at NAME (FILE:LINE:COLUMN)'.  The
  ;; built-in `java' rule matches that shape too, but it has no column
  ;; group, so it takes `:LINE' to be part of the file name and COLUMN
  ;; to be the line.
  (add-to-list 'compilation-error-regexp-alist-alist
               '(my/node-frame
                 "^[ \t]*at \\(?:.*(\\)?\\([^()]+\\):\\([0-9]+\\):\\([0-9]+\\))?$"
                 1 2 3))

  (define-derived-mode my/vscode-test-mode compilation-mode "Sigasi-Test"
    "Compilation mode for a `sigasi-dev' test run."
    (setq-local compilation-error-regexp-alist '(my/node-frame))
    (setq-local compilation-transform-file-match-alist '(("node:" nil)))
    (add-hook 'compilation-filter-hook #'my/vscode-test-attach nil t)
    ;; Without this the escapes show up as text.
    (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter nil t))

  (define-key evil-normal-state-map (kbd ",t") #'my/vscode-test)
  (define-key evil-normal-state-map (kbd ",T") #'my/vscode-test-debug))

;;;; Dape: IntelliJ JVM attach
;; The server implements DAP but reaches it only over LSP: `start_debug_server'
;; starts an adapter and answers with its port.  The debuggee is reached by
;; JDWP, so start it listening first -- `-DdebugPort=5005' for a tycho-surefire
;; run, 5011 for the infinite-server launch group.
(use-package dape
  :ensure nil
  :config
  (defvar my/jvm-debug-port 5005
    "JDWP port the debuggee is listening on.")

  ;; The adapter reports `Source.path' as a `file://' URI where DAP wants a
  ;; plain path, so `dape--object-to-marker' finds no file and drops the
  ;; stack-frame overlay.
  (defun my/dape-uri-to-file-name (path)
    "Convert a `file://' URI to a file name; pass anything else through."
    (if (and (stringp path) (string-prefix-p "file://" path))
        (url-unhex-string (url-filename (url-generic-parse-url path)))
      path))

  (advice-add 'dape--file-name-local :filter-return #'my/dape-uri-to-file-name)

  ;; Merely evaluating dape's own `jdtls' config fires
  ;; `vscode.java.resolveMainClass' at whatever server is attached, malformed.
  (setq dape-configs (assq-delete-all 'jdtls dape-configs))

  (defvar my/sigasi-lsp-server-source
    "com.sigasi.lsp.server/src/com/sigasi/lsp/server/LspServer.java"
    "Source of the LSP server main class, relative to the project root.")

  (defun my/intellij-resolve-launch (file)
    "Ask the server for FILE's JVM launch paths, a `JvmLaunchPaths'."
    (eglot-execute (eglot-current-server)
                   `(:command "intellij.java.resolveLaunch"
                              :arguments [( :uri ,(eglot-path-to-uri file)
                                            :cwd ,(file-name-directory file))])))

  (defun my/intellij-dap-port ()
    "Start the IntelliJ server's DAP adapter and return its port."
    (eglot-execute (eglot-current-server) '(:command "start_debug_server")))

  (add-to-list 'dape-configs
               `(sigasi-java
                 modes (java-mode java-ts-mode)
                 ensure ,(lambda (_config)
                           (unless (eglot-current-server)
                             (user-error "No eglot connection in %s" (buffer-name)))
                           (unless (seq-contains-p
                                    (eglot-server-capable :executeCommandProvider :commands)
                                    "start_debug_server")
                             (user-error "This language server provides no DAP adapter")))
                 ;; `port' reaches the adapter; `:port' is the JDWP port.
                 fn ,(lambda (config)
                       (plist-put config 'port (my/intellij-dap-port)))
                 ;; `:type' is the DAP adapterID; the server knows only its own.
                 :type "intellij_jvm"
                 :request "attach"
                 :port my/jvm-debug-port))

  ;; `lsp-server.launch' as a DAP launch.  Not the infinite-server harness: it
  ;; spawns its child with `server=n', which needs a *listening* debugger.
  (add-to-list 'dape-configs
               `(sigasi-lsp-server
                 modes (java-mode java-ts-mode)
                 ensure ,(plist-get (alist-get 'sigasi-java dape-configs) 'ensure)
                 ;; The adapter infers nothing: it demands javaExec and paths.
                 fn ,(lambda (config)
                       (let* ((root (project-root
                                     (or (project-current)
                                         (user-error "Not inside a project"))))
                              (file (expand-file-name my/sigasi-lsp-server-source root))
                              (paths (progn
                                       (unless (file-exists-p file)
                                         (user-error "No %s under %s" my/sigasi-lsp-server-source root))
                                       (my/intellij-resolve-launch file))))
                         (thread-first
                           config
                           (plist-put 'port (my/intellij-dap-port))
                           (plist-put :javaExec (plist-get paths :javaExec))
                           (plist-put :classPaths (plist-get paths :classpath))
                           (plist-put :modulePaths (plist-get paths :modulePath))
                           (plist-put :moduleContentPaths (plist-get paths :moduleContentPaths))
                           (plist-put :cwd (or (plist-get paths :workingDirectory) root)))))
                 :type "intellij_jvm"
                 :request "launch"
                 ;; No `moduleName': the adapter reads it as a JPMS module, and
                 ;; this codebase has no module-info.java.
                 :mainClass "com.sigasi.lsp.server.LspServer"
                 ;; A List<String>: a joined string serialises as a JsonLiteral.
                 :vmArgs ["-Dguice_bytecode_gen_option=DISABLED"
                          "--enable-native-access=ALL-UNNAMED"
                          "--sun-misc-unsafe-memory-access=allow"
                          "-Xmx8g" "-Xss4m"
                          "-XX:+UseCompressedOops" "-XX:+UseG1GC"
                          "-XX:G1PeriodicGCInterval=60000"
                          "-XX:-G1PeriodicGCInvokesConcurrent"
                          "-XX:MinHeapFreeRatio=5" "-XX:MaxHeapFreeRatio=30"
                          "-XX:+UseStringDeduplication"
                          "-Dsigasi.dev.mode=true"])))

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
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :config
  :hook (typescript-ts-base-mode . eglot-ensure))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode)
  :commands (gfm-view-mode markdown-view-mode)
  :custom (markdown-command "/usr/bin/pandoc"))
