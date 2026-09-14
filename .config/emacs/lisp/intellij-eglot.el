;; -*- lexical-binding: t; -*-
(require 'eglot)
(require 'project)
(require 'xdg)

(defconst intellij-server-dir
  (expand-file-name "intellij-server/current" (xdg-data-home)))

(defconst intellij-server-data-dir
  (expand-file-name "intellij-server/emacs" (xdg-cache-home)))

(defun intellij-server--eula-hash ()
  "First 16 chars of the SHA-256 of the server EULA; required since 0.0.10."
  (let ((f (expand-file-name "EULA.txt" intellij-server-dir)))
    (substring (with-temp-buffer
                 (set-buffer-multibyte nil)
                 (insert-file-contents-literally f)
                 (secure-hash 'sha256 (buffer-string)))
               0 16)))

(defclass intellij-server-eglot (eglot-lsp-server) ()
  :documentation "IntelliJ IDEA language server.")

(defun intellij-server--project-spec (root)
  "Gradle import spec for ROOT, with JDK and Gradle home from the environment."
  (let ((java-home (getenv "JAVA_HOME"))
        (spec (list :type "gradle"
                    :path (concat "file://"
                                  (directory-file-name (expand-file-name root)))
                    :env (list :GRADLE_USER_HOME
                               (or (getenv "GRADLE_USER_HOME")
                                   (expand-file-name "gradle" (xdg-data-home)))))))
    ;; Omit the key when JAVA_HOME is unset rather than sending null, so the
    ;; server falls back to its own JDK detection.
    (if (and java-home (not (string-empty-p java-home)))
        (plist-put spec :java-home
                   (directory-file-name (expand-file-name java-home)))
      spec)))

(cl-defmethod eglot-initialization-options ((server intellij-server-eglot))
  "Force a Gradle import of this project rather than a Maven one."
  `(:projects [,(intellij-server--project-spec
                 (project-root (eglot--project server)))]))

(defun intellij-server-contact (&optional _interactive _project)
  "Command line for the server, with its environment applied via `env'."
  (let ((jbr (expand-file-name "jbr" intellij-server-dir)))
    (list "env"
          (concat "JAVA_HOME=" jbr)
          (concat "IJ_JAVA_OPTIONS="
                  (string-join
                   (list (concat "-Didea.config.path=" intellij-server-data-dir "/config")
                         (concat "-Didea.system.path=" intellij-server-data-dir "/system")
                         (concat "-Didea.log.path=" intellij-server-data-dir "/log")
                         (concat "-XX:HeapDumpPath=" intellij-server-data-dir "/log")
                         "-Xmx8g")
                   " "))
          (expand-file-name "bin/intellij-server" intellij-server-dir)
          "--stdio"
          "--eula" (intellij-server--eula-hash))))

(add-to-list 'eglot-server-programs
             `((java-mode java-ts-mode) . (intellij-server-eglot
                                           . ,(intellij-server-contact))))
(provide 'intellij-eglot)
