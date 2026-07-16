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

;;; Basic behavior

(setq inhibit-startup-screen t)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.local/state/emacs/
(setq backup-directory-alist '(("." . "~/.local/state/emacs/backup")))
(setq auto-save-file-name-transforms '((".*" "~/.local/state/emacs/autosave/\\1" t)))
(make-directory "~/.local/state/emacs/autosave/" t)

(use-package recentf
  :hook (after-init . recentf-mode))

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

(setq global-auto-revert-mode t)

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
  (exec-path-from-shell-initialize))

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
  (setq evil-want-Y-yank-to-eol 1)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  (define-key evil-insert-state-map (kbd "C-SPC") 'completion-at-point)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "DEL") nil)

  (setq evil-symbol-word-search t)

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

  (defvar my/consult-source-git-repos
    (list :name   "Git Repositories"
          :narrow ?g
          :items  (lambda () (mapcar #'car my/consult-git-repos-cache))
          :action (lambda (name)
                    (magit-status (cdr (assoc name my/consult-git-repos-cache))))))
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
    (magit-status
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
  :config
  (setq magit-list-refs-sortby "-committerdate")
  (setq magit-diff-refine-hunk 'all)
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)

  (defun my/magit-diff-origin-master (&optional args files)
    "Diff the current branch against origin's default branch."
    (interactive (magit-diff-arguments))
    (let ((main (or (magit-git-string "symbolic-ref" "--short"
                                      "refs/remotes/origin/HEAD")
                    "origin/master")))
      (magit-diff-setup-buffer (concat main "...") nil args files 'committed)))
  (transient-append-suffix 'magit-diff "r"
    '("o" "Diff origin/master..." my/magit-diff-origin-master))

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
    (evil-define-key 'normal magit-process-mode-map (kbd "gx") 'browse-url-at-point)))

(use-package magit-delta
  :ensure t
  :after magit
  :hook (magit-mode . magit-delta-mode)
  :config
  (setq magit-delta-default-light-theme "ansi"))

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
                 :port 9229
                 :cwd dape-cwd-fn
                 :sourceMaps t
                 :resolveSourceMapLocations ["${workspaceFolder}/**" "!**/node_modules/**"]))

  (defvar my/sigasi-auto-reconnect nil)
  (defvar my/sigasi-reconnect-timer nil)

  (defun my/sigasi-cancel-reconnect ()
    (when (timerp my/sigasi-reconnect-timer)
      (cancel-timer my/sigasi-reconnect-timer))
    (setq my/sigasi-reconnect-timer nil))

  (defun my/sigasi-check-reconnect ()
    "Schedule a dape reconnect when the session terminates unexpectedly."
    (when (and my/sigasi-auto-reconnect (not dape--connections))
      (my/sigasi-cancel-reconnect)
      (setq my/sigasi-reconnect-timer
            (run-with-timer 2 nil
                            (lambda ()
                              (when my/sigasi-auto-reconnect
                                (condition-case err
                                    (dape (dape--config-eval 'sigasi-extension nil))
                                  (error (message "Sigasi auto-reconnect failed: %s" err)))))))))

  (add-hook 'dape-update-ui-hook #'my/sigasi-check-reconnect)

  (defun my/sigasi-dape-quit-cleanup (&rest _)
    (setq my/sigasi-auto-reconnect nil)
    (my/sigasi-cancel-reconnect)
    (when-let* ((proc (get-process "sigasi-compile-watch")))
      (delete-process proc)))
  (advice-add 'dape-quit :before #'my/sigasi-dape-quit-cleanup)

  (defun my/sigasi-debug ()
    "Start VS Code extension-development host and attach dape."
    (interactive)
    (setq my/sigasi-auto-reconnect t)
    (bookmark-maybe-load-default-file)
    (when-let* ((vscode-bm  (bookmark-get-bookmark "vscode" t))
                (vscode-dir (expand-file-name (bookmark-get-filename vscode-bm))))
      (unless (cl-some (lambda (buf)
                         (when-let* ((file (buffer-file-name buf)))
                           (string-prefix-p vscode-dir (expand-file-name file))))
                       (buffer-list))
        (bookmark-jump "vscode"))
      (unless (get-process "sigasi-compile-watch")
        (let ((default-directory vscode-dir))
          (start-process "sigasi-compile-watch"
                         (get-buffer-create "*sigasi-compile-watch*")
                         "yarn" "compile:watch")))
      (let ((process-environment (cons "RELOAD_ON_WATCH=true" process-environment)))
        (start-process "sigasi-debug-host" nil "code"
                       "--extensionDevelopmentPath"
                       vscode-dir
                       "--inspect-extensions" "9229")))
    (dape (dape--config-eval 'sigasi-extension nil)))

  (define-key evil-normal-state-map (kbd "<f5>") #'my/sigasi-debug)

  (transient-define-prefix my/dape-transient ()
    "Dape debug commands."
    [["Session"
      ("d" "launch"   dape)
      ("r" "restart"  dape-restart)
      ("Q" "stop"     dape-quit)]
     ["Step"
      ("c" "continue" dape-continue        :transient t)
      ("n" "next"     dape-next            :transient t)
      ("i" "step-in"  dape-step-in         :transient t)
      ("o" "step-out" dape-step-out        :transient t)
      ("p" "pause"    dape-pause           :transient t)
      ("u" "until"    dape-until           :transient t)]
     ["Breakpoints"
      ("b" "toggle"     dape-breakpoint-toggle)
      ("B" "condition"  dape-breakpoint-expression)
      ("l" "log"        dape-breakpoint-log)
      ("h" "hits"       dape-breakpoint-hits)
      ("x" "remove all" dape-breakpoint-remove-all)]
     ["Inspect"
      ("e" "eval"       dape-evaluate-expression)
      ("w" "watch"      dape-watch-dwim)
      ("s" "stack"      dape-select-stack)
      ("S-k" "frame up"   dape-stack-select-up   :transient t)
      ("S-j" "frame down" dape-stack-select-down :transient t)]])

  (define-key evil-normal-state-map (kbd "<SPC>d") #'my/dape-transient))

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
