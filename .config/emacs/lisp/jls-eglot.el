;; -*- lexical-binding: t; -*-
;; Java via jls (https://github.com/idelice/jls), a javac-based language server.
;; Runs the local build in `jls-dir', patched for the Sigasi Gradle build; rebuild with
;;   HOST_JDK=/usr/lib/jvm/temurin-25-jdk MVN=<mvn> ./scripts/build.sh
(require 'eglot)
(require 'project)
(require 'xdg)
;; Shares the Gradle watch and the "sigasi" bookmark root with the IntelliJ server.
(require 'intellij-eglot)

(defvar jls-dir (expand-file-name "~/git_repos/jls/")
  "Checkout jls was built in.")

(defvar jls-jvm-options
  '("-Xmx4g" "-Xms512m" "-XX:MaxHeapFreeRatio=50" "-XX:MinHeapFreeRatio=20"
    "-XX:+UseStringDeduplication")
  "JVM options, in place of the launcher's defaults (which cap the heap at 2g).")

(defclass jls-eglot (eglot-lsp-server) ()
  :documentation "jls Java language server.")

;;; Preflight

(defun jls--preflight ()
  "Signal a `user-error' naming the fix when the server cannot start."
  (let ((launcher (expand-file-name "dist/lang_server_linux.sh" jls-dir))
        (java (expand-file-name "dist/linux/bin/java" jls-dir))
        (jar (expand-file-name "dist/classpath/jls.jar" jls-dir)))
    (unless (file-executable-p launcher)
      (user-error "No jls launcher at %s" launcher))
    (unless (and (file-executable-p java) (file-readable-p jar))
      (user-error "jls in %s is not built: run HOST_JDK=<jdk> ./scripts/build.sh there"
                  jls-dir))))

;;; Autoload

(defun jls-ensure ()
  "Start the Gradle watch, then manage this buffer with eglot.
Only in the repository `sigasi-dev' builds; elsewhere, do nothing.
For a Java mode hook, in place of `eglot-ensure'.  The watch keeps the
generated sources under build/generated, which jls reads, up to date."
  (unless (intellij-server--uri-buffer-p)
    (condition-case err
        (let* ((project (project-current))
               (root (and project (project-root project)))
               (sigasi (intellij-server--sigasi-root)))
          (when (and root sigasi (file-equal-p root sigasi))
            (jls--preflight)
            (intellij-server--gradle-start sigasi (current-buffer))))
      ;; A mode hook must not signal, or it interrupts visiting the file.
      ((user-error file-error)
       (display-warning 'jls (error-message-string err) :error)))))

;;; Registration

(defun jls-contact (&optional _interactive _project)
  "Class and command line for the server, its environment applied via `env'."
  (jls--preflight)
  (cons 'jls-eglot
        (list "env"
              ;; jls runs gradlew itself, which needs the token in this Gradle home.
              (concat "GRADLE_USER_HOME="
                      (or (getenv "GRADLE_USER_HOME")
                          (expand-file-name "gradle" (xdg-data-home))))
              (concat "JLS_JVM_OPTS=" (string-join jls-jvm-options " "))
              (expand-file-name "dist/lang_server_linux.sh" jls-dir))))

;;; Debugging
;; jls ships a separate DAP adapter, over stdio, that attaches only.

(defun jls-debug-adapter ()
  "The jls DAP adapter's launcher."
  (jls--preflight)
  (expand-file-name "dist/debug_adapter_linux.sh" jls-dir))

(defun jls--read-graph (file)
  "The module graph cached in FILE, as a list of module plists."
  (with-temp-buffer
    (insert-file-contents file)
    (plist-get (json-parse-buffer :object-type 'plist :array-type 'list)
               :modules)))

(defun jls-source-roots (root)
  "Source directories of every module of the Gradle build at ROOT.
Read from the module graph the server cached, newest first: the adapter
maps a frame to its file by searching these, and has no build model."
  (let* ((root (directory-file-name (expand-file-name root)))
         ;; <cache>/jls/<root's name>-<path hash>/<build fingerprint>/graph.json
         (pattern (expand-file-name
                   (format "jls/%s-*/*/graph.json" (file-name-nondirectory root))
                   (xdg-cache-home)))
         (graphs (sort (file-expand-wildcards pattern) #'file-newer-than-file-p))
         (modules (seq-some
                   (lambda (file)
                     (let ((modules (jls--read-graph file)))
                       ;; The name alone can match another checkout.
                       (and (seq-some (lambda (module)
                                        (and (equal (plist-get module :projectPath) ":")
                                             (file-equal-p (plist-get module :projectDir) root)))
                                      modules)
                            modules)))
                   graphs)))
    (unless modules
      (user-error "jls has not resolved %s yet: open one of its Java files first" root))
    (seq-uniq (mapcan (lambda (module) (copy-sequence (plist-get module :sourceDirs)))
                      modules))))

(provide 'jls-eglot)
