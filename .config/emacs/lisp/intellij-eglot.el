;; -*- lexical-binding: t; -*-
(require 'eglot)
(require 'project)
(require 'xdg)

(defconst intellij-server-dir
  (expand-file-name "intellij-server/current" (xdg-data-home)))

(defconst intellij-server-data-dir
  (expand-file-name "intellij-server/emacs" (xdg-cache-home)))

(defclass intellij-server-eglot (eglot-lsp-server) ()
  :documentation "IntelliJ IDEA language server.")

;;; Preflight

(defun intellij-server--preflight ()
  "Signal a `user-error' naming the fix when the server cannot start."
  (let ((launcher (expand-file-name "bin/intellij-server" intellij-server-dir))
        (jbr (expand-file-name "jbr/bin/java" intellij-server-dir))
        (eula (expand-file-name "EULA.txt" intellij-server-dir)))
    (unless (file-directory-p intellij-server-dir)
      (user-error "No IntelliJ server at %s: install one and point the `current' symlink at it"
                  intellij-server-dir))
    (unless (file-executable-p launcher)
      (user-error "IntelliJ server launcher %s is missing or not executable"
                  launcher))
    (unless (file-executable-p jbr)
      (user-error "IntelliJ server at %s bundles no JBR (expected %s)"
                  intellij-server-dir jbr))
    (unless (file-readable-p eula)
      (user-error "Cannot read %s, so the --eula hash the server demands cannot be computed"
                  eula))))

;;; Project import

(defun intellij-server--project-spec (root)
  "Gradle import spec for ROOT, with JDK and Gradle home from the environment."
  (let ((java-home (getenv "JAVA_HOME"))
        (spec (list :type "gradle"
                    :path (concat "file://"
                                  (directory-file-name (expand-file-name root)))
                    :env (list :GRADLE_USER_HOME
                               (or (getenv "GRADLE_USER_HOME")
                                   (expand-file-name "gradle" (xdg-data-home)))))))
    ;; Omit when unset rather than sending null; the server then finds its own.
    (if (and java-home (not (string-empty-p java-home)))
        (plist-put spec :java-home
                   (directory-file-name (expand-file-name java-home)))
      spec)))

(cl-defmethod eglot-initialization-options ((server intellij-server-eglot))
  "Force a Gradle import of this project rather than a Maven one."
  `(:projects [,(intellij-server--project-spec
                 (project-root (eglot--project server)))]))

;;; Library sources
;; Eglot passes non-`file:' URIs through for `file-name-handler-alist' to
;; open -- jarchive's job -- but jarchive only matches `jar:file://'.
;;
;; A class with no attached source points into the binary jar.  PDE's bundle
;; pool holds the `.source' bundles for the current target platform that
;; `.repository' lacks, which is why Eclipse can navigate to them.

(defconst intellij-server--jar-class-regexp
  "\\`jar:file://\\(/.*\\.\\(?:jar\\|zip\\)\\)!/\\(.*\\)\\.class\\'"
  "Matches a jarchive URI naming a `.class' entry rather than a source file.")

(defvar intellij-server-source-pools
  (list (expand-file-name
         "sigasi/ws/.metadata/.plugins/org.eclipse.pde.core/.bundle_pool/plugins"
         "~")
        (expand-file-name ".p2/pool/plugins" "~"))
  "Directories searched in order for OSGi source bundles.")

(defun intellij-server--pool-source-jar (name version)
  "Find NAME's source bundle at VERSION in the source pools."
  (seq-some (lambda (dir)
              (let ((jar (expand-file-name
                          (format "%s.source_%s.jar" name version) dir)))
                (and (file-readable-p jar) jar)))
            intellij-server-source-pools))

(defun intellij-server--source-bundle-uri (uri)
  "Source-bundle URI for the `.class' named by URI, or nil if no pool has it."
  (when (string-match intellij-server--jar-class-regexp uri)
    (let ((base (file-name-base (match-string 1 uri)))
          (entry (match-string 2 uri)))
      ;; An OSGi version has its own hyphen: org.eclipse.osgi-3.24.200.v1-2.
      (when (string-match "\\`\\(.*?\\)-\\([0-9].*\\)\\'" base)
        (when-let* ((jar (intellij-server--pool-source-jar
                          (match-string 1 base) (match-string 2 base))))
          (concat "jar:file://" jar "!/" entry ".java"))))))

(defun intellij-server--normalize-jar-uri (path)
  "Respell a `jar:///' PATH for jarchive, sending a `.class' to its source."
  (if (string-prefix-p "jar:///" path)
      (let ((uri (concat "jar:file:" (substring path (length "jar:")))))
        (or (intellij-server--source-bundle-uri uri) uri))
    path))

(advice-add 'eglot-uri-to-path :filter-return
            #'intellij-server--normalize-jar-uri)

(defun intellij-server--uri-buffer-p ()
  "Non-nil when this buffer's file name is a URI rather than a local path."
  (and buffer-file-name
       (string-match-p "\\`[a-z][a-z0-9+.-]+:" buffer-file-name)))

;;; Gradle preflight
;; The server imports by running Gradle itself and says nothing meanwhile, so
;; a cold cache looks like a hang.  Run it here first, where it is visible.
;;
;; Simple Tycho writes `gradle/tycho/' during configuration, so `help' -- the
;; cheapest task that configures -- suffices, and Gradle's own input tracking
;; decides whether anything needs redoing.  Warm that is under a second.

(defvar intellij-server-gradle-args '("--console=plain" "help")
  "Arguments to the project's `gradlew' for the preflight build.")

(defvar intellij-server-gradle-reveal-delay 2
  "Seconds the preflight build may run unseen before its buffer is shown.")

(defvar intellij-server--gradle-process nil)

(defvar intellij-server--gradle-root nil
  "Project root the running preflight build belongs to.")

(defvar intellij-server--gradle-pending nil
  "Buffers to hand to eglot once the running preflight build succeeds.")

(defvar intellij-server--gradle-checked nil
  "Project roots whose preflight build has already succeeded this session.")

(defun intellij-server--gradle-filter (proc string)
  "Append STRING to PROC's buffer, keeping point at the end when it was there."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((inhibit-read-only t)
            (follow (= (point) (process-mark proc))))
        (save-excursion
          (goto-char (process-mark proc))
          (insert string)
          (set-marker (process-mark proc) (point)))
        (when follow (goto-char (process-mark proc)))))))

(defun intellij-server--gradle-finish (proc)
  "Connect the buffers that waited for PROC, or show why its build failed."
  (let ((buffers intellij-server--gradle-pending)
        (status (process-exit-status proc)))
    (setq intellij-server--gradle-pending nil)
    (if (not (eq status 0))
        (progn
          ;; Gradle names the cause far better than the server would.
          (display-buffer (process-buffer proc))
          (message "Gradle preflight failed (exit %s); IntelliJ server not started"
                   status))
      (push intellij-server--gradle-root intellij-server--gradle-checked)
      (dolist (buffer buffers)
        (when (buffer-live-p buffer)
          (with-current-buffer buffer (eglot-ensure)))))))

(defun intellij-server--gradle-start (root buffer)
  "Build the Gradle IDE model for ROOT, then manage BUFFER with eglot.
Returns at once; buffers arriving mid-build join the one in flight."
  (push buffer intellij-server--gradle-pending)
  (unless (process-live-p intellij-server--gradle-process)
    (let* ((default-directory root)
           (out (get-buffer-create "*intellij-server gradle*"))
           (reveal (run-at-time
                    intellij-server-gradle-reveal-delay nil
                    (lambda ()
                      (message "Building the Gradle IDE model...")
                      (display-buffer out)))))
      (with-current-buffer out
        (let ((inhibit-read-only t)) (erase-buffer))
        (setq default-directory root))
      (setq intellij-server--gradle-root root)
      (setq intellij-server--gradle-process
            (make-process
             :name "intellij-server-gradle"
             :buffer out
             :command (cons (expand-file-name "gradlew" root)
                            intellij-server-gradle-args)
             :noquery t
             :filter #'intellij-server--gradle-filter
             :sentinel
             (lambda (proc _event)
               (unless (process-live-p proc)
                 (cancel-timer reveal)
                 (intellij-server--gradle-finish proc))))))))

;;; Diagnostic filtering

(defvar intellij-server-filter-diagnostics t
  "When non-nil, keep only diagnostics Eclipse would also report.")

(defvar intellij-server-eclipse-inspections
  '("unused" "UNUSED_IMPORT" "UnusedLabel" "RedundantThrows"
    "Deprecation" "MarkedForRemoval" "MissingDeprecatedAnnotation"
    "MissingOverrideAnnotation"
    "SillyAssignment" "AssignmentUsedAsCondition"
    "EmptyStatementBody" "AccessStaticViaInstance" "MethodNameSameAsClassName"
    "EqualsBetweenInconvertibleTypes" "SuspiciousMethodCalls"
    "EnumSwitchStatementWhichMissesCases"
    "DataFlowIssue" "ConstantValue" "NullableProblems"
    "AutoCloseableResource"
    "RawUseOfParameterizedType" "JavadocDeclaration" "JavadocReference"
    "SerializableHasSerialVersionUIDField"
    "FinallyBlockCannotCompleteNormally" "UnreachableCode")
  "Inspection ids kept, mapped from the =warning entries in
com.sigasi.hdt.target/settings/org.eclipse.jdt.core.prefs.
The mapping is approximate, and Eclipse's OSGi access-rule warnings
\(forbiddenReference, discouragedReference, APILeak) have no analogue.
To add one, read the id from the `[code]' eglot puts in the message.")

(defun intellij-server--keep-diagnostic-p (diag)
  "Non-nil if DIAG should survive filtering."
  (let ((severity (plist-get diag :severity))
        (code (plist-get diag :code)))
    (or (not intellij-server-filter-diagnostics)
        (and (numberp severity) (<= severity 1))
        ;; No id means a compiler-level diagnostic, which Eclipse reports too.
        (null code)
        (member (format "%s" code) intellij-server-eclipse-inspections))))

(cl-defmethod eglot-handle-notification :around
  ((server intellij-server-eglot)
   (method (eql textDocument/publishDiagnostics))
   &rest args &key diagnostics &allow-other-keys)
  "Drop inspections this project would not enable in Eclipse."
  (apply #'cl-call-next-method server method
         (plist-put (copy-sequence args) :diagnostics
                    (cl-remove-if-not #'intellij-server--keep-diagnostic-p
                                      diagnostics))))

;;; Autoload
(defun intellij-server-ensure ()
  "Bring the Gradle IDE model up to date, then manage this buffer with eglot.
For a Java mode hook, in place of `eglot-ensure'."
  (unless (intellij-server--uri-buffer-p)
    (condition-case err
        (let* ((project (project-current))
               (root (and project (project-root project))))
          (intellij-server--preflight)
          (if (and root
                   (file-executable-p (expand-file-name "gradlew" root))
                   (not (member root intellij-server--gradle-checked)))
              (intellij-server--gradle-start root (current-buffer))
            (eglot-ensure)))
      ;; A mode hook must not signal, or it interrupts visiting the file.
      (user-error
       (display-warning 'intellij-server (error-message-string err) :error)))))

;;; Registration

(defun intellij-server--eula-hash ()
  "First 16 chars of the SHA-256 of the server EULA; required since 0.0.10."
  (let ((f (expand-file-name "EULA.txt" intellij-server-dir)))
    (substring (with-temp-buffer
                 (set-buffer-multibyte nil)
                 (insert-file-contents-literally f)
                 (secure-hash 'sha256 (buffer-string)))
               0 16)))

(defun intellij-server-contact (&optional _interactive _project)
  "Class and command line for the server, its environment applied via `env'."
  (intellij-server--preflight)
  (let ((jbr (expand-file-name "jbr" intellij-server-dir)))
    (cons 'intellij-server-eglot
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
                "--eula" (intellij-server--eula-hash)))))

;; A function, not a literal: re-resolved per connection, not once at load.
(add-to-list 'eglot-server-programs
             '((java-mode java-ts-mode) . intellij-server-contact))

(provide 'intellij-eglot)
