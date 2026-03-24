(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(use-package dash
  :ensure t)
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-Y-yank-to-eol 1)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-normal-state-map  (kbd "U") 'evil-redo)
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
(use-package evil-collection
  :ensure t
  :config
  (evil-collection-init))
(use-package magit
  :ensure t)
(use-package sly
  :ensure nil
  :config
  (setq sly-mrepl-history-file-name "/home/vital/.local/state/sly-mrepl-history")
  (setq inferior-lisp-program "sbcl"))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'prot/keyboard-quit-dwim)

(load-theme 'modus-operandi-tinted)

(let ((mono-spaced-font "FiraCode Nerd Font Mono")
      (proportionately-spaced-font "FiraCode Nerd Font Propo"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 108)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))

(setq backup-directory-alist '(("." . "~/.local/state/emacs/backup")))
(show-paren-mode 1)

(setq scroll-step 1)
(setq scroll-margin 1)
