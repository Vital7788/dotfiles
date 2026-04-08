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

;;; Basic behavior

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.local/state/emacs/
(setq backup-directory-alist '(("." . "~/.local/state/emacs/backup")))
(setq auto-save-file-name-transforms '((".*" "~/.local/state/emacs/autosave/\\1" t)))
(make-directory "~/.local/state/autosave/" t)

(setq tab-width 4)

(show-paren-mode 1)

(setq scroll-step 1)
(setq scroll-margin 1)

;;; Appearance

(load-theme 'modus-operandi-tinted)

(let ((mono-spaced-font "IBM Plex Mono")
      (proportionately-spaced-font "IBM Plex Serif"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 105 :weight 'light)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0 :weight 'normal))

(blink-cursor-mode 0)

;;; Evil

(use-package dash
  :ensure t)

(use-package evil
  :after dash
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-Y-yank-to-eol 1)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  (define-key evil-normal-state-map (kbd "SPC e") 'eval-last-sexp)

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
	      :filter-return #'my/magit-process-environment)

  (when (not (display-graphic-p))
    (add-hook 'evil-insert-state-entry-hook (lambda () (send-string-to-terminal "\033[6 q")))
    (add-hook 'evil-insert-state-exit-hook  (lambda () (send-string-to-terminal "\033[2 q")))))

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

;;; Minibuffer
;; More advanced stuff here: https://protesilaos.com/codelog/2024-02-17-emacs-modern-minibuffer-packages/

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode))

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
  :config
  ;; A recursive grep
  (define-key evil-normal-state-map (kbd ",g") 'consult-ripgrep)
  ;; Search for files names recursively
  (define-key evil-normal-state-map (kbd ",f") 'consult-fd)
  ;; Search through the outline (headings) of the file
  (define-key evil-normal-state-map (kbd ",o") 'consult-outline)
  ;; Search the current buffer
  (define-key evil-normal-state-map (kbd ",l") 'consult-line)
  ;; Switch to another buffer, or bookmarked file, or recently opened file.
  (define-key evil-normal-state-map (kbd ",b") 'consult-buffer))

;;; File manager (Dired)

(use-package dired
  :ensure nil
  :commands (dired)
  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  ( :map dired-mode-map
    ("<tab>" . dired-subtree-toggle)
    ("TAB" . dired-subtree-toggle)))

;;; Magit
(use-package magit
  :ensure t
  :init
  (setq magit-define-global-key-bindings 'recommended)
  :config
  (setq magit-list-refs-sortby "-committerdate")
  (defun my/magit-open-file-in-eclipse ()
    "Open the file under the cursor in Eclipse"
    (interactive)
    (let* ((repo-path (magit-repository-local-repository))
	   (command (format "%s../../eclipse/eclipse --launcher.openFile %s%s" repo-path repo-path (magit-current-file))))
      (start-process-shell-command "eclipse-launcher" nil command)))
  (evil-define-key 'normal magit-mode-map (kbd "gx") 'my/magit-open-file-in-eclipse))

(use-package forge
  :after magit
  :ensure t
  :config
  (push '("gitlab.sigasi.com"
	  "gitlab.sigasi.com/api/v4"
	  "gitlab.sigasi.com"
	  forge-gitlab-repository)
	forge-alist)
  (setq auth-sources '("~/.authinfo")))

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
  (add-hook 'org-mode-hook 'visual-line-mode) ; wrap lines
  (add-hook 'org-mode-hook 'variable-pitch-mode) ; proportionally spaced font

  ;; Substitute list markers ("-" -> "•")
  (font-lock-add-keywords 'org-mode
			  '(("^ *\\([-]\\) "
			     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  (let* ((variable-tuple
	  (cond ((x-list-fonts "IBM Plex Serif")  '(:font "IBM Plex Serif"))
		((x-list-fonts "ETBembo")         '(:font "ETBembo"))
		((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
		((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
		((x-list-fonts "Verdana")         '(:font "Verdana"))
		((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
		(nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
	 (base-font-color     (face-foreground 'default nil 'default))
	 (headline           `(:inherit default :weight bold :foreground ,base-font-color)))
    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.2))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.3))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.5))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 1.6 :underline nil)))))))

     '(org-block ((t (:inherit (fixed-pitch) :weight light))))
     '(org-block-begin-line ((t (:inherit fixed-pitch))))
     '(org-code ((t (:inherit (shadow fixed-pitch)))))
     '(org-document-info ((t (:foreground "dark orange"))))
     '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
     '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
     '(org-link ((t (:foreground "royal blue" :underline t))))
     '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
     '(org-property-value ((t (:inherit fixed-pitch))) t)
     '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
     '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
     '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
     '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))))

;;; Language specific
(use-package sly
  :ensure nil
  :config
  (setq sly-mrepl-history-file-name "/home/vital/.local/state/sly-mrepl-history")
  (setq inferior-lisp-program "sbcl"))
