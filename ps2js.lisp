(in-package :ps2js)

;;; Special vars to be set, most important first.
;;; Ensure your directories have a trailing slash.

(defparameter *ps-dir* "/tmp/ps/"
  "The directory in which your source Parenscript files live.")

(defparameter *js-dir* "/tmp/js/"
  "The directory in which to write the compiled JavaScript files.")

(defparameter *main-file* "main.js"
  "The name of the main JavaScript file for user code of your project.
This must be the JS version of your main Parenscript file.")

(defparameter *npm-dir* "/home/gtod/"
  "The directory under which your node dependencies are installed.
Must contain a package.json file with those dependencies list.")

(defparameter *extra-npm-dependencies* nil
  "Usualy your deps should be listed in package.json.  But, for example,
react/addons has no place in there because it is part of react proper.
Yet we do want it in our vendor bundle...  So put the same string you
would put in your require stmt in JS in a list here for those
troublesome extra deps.")

(defparameter *browserify* "/usr/local/bin/browserify"
  "The full pathname of the browserify executable.")

(defparameter *uglifyjs* "/usr/bin/uglifyjs"
  "The full pathname of the uglifyjs executable.")

;; Needs -r arg to write output in place
(defparameter *js-beautify-cmd* "/usr/local/bin/js-beautify"
  "The full pathname of the js-beautify executable.")

(defparameter *vendor-bundle-file* "vendor-bundle.js"
  "The name of the resulting bundled JavaScript dependencies for your
project.")

(defparameter *main-bundle-file* "main-bundle.js"
  "The name of the resulting bundled JavaScript file for user code of
your project.")

(defparameter *sleep-time* 0.2
  "The time in seconds to sleep before waking up to check for modified
input Parenscript files.")

;;;; Implementation

(defun package-json-file ()
  (merge-pathnames* *npm-dir* "package.json"))

(defun node-dependencies ()
  (with-input-from-file (stream (package-json-file))
    (append
     *extra-npm-dependencies*
     (hash-table-keys (gethash "dependencies" (yason:parse stream))))))

(defun replace-file-extension (file-name ext)
  "Replace the file extension of FILE with EXT."
  (let ((name (file-namestring file-name))
        (type (pathname-type file-name)))
    (cl-ppcre:regex-replace (format nil ".~A$" type) name (format nil ".~A" ext))))

(defun beautify-js (file)
  "Beautify the JavaScript file FILE in place, using js-beautify."
  (with-current-directory (*js-dir*)
    (run-program (format nil "~A ~A -r" *js-beautify-cmd* file))))

(defun ps2js-file (parenscript-file)
  "Parenscript compile PARENSCRIPT-FILE to a JavaScript file.
Input file from *PS-DIR* and output file to *JS-DIR*."
  (let* ((in-file (merge-pathnames* *ps-dir* parenscript-file))
         (js-file (replace-file-extension parenscript-file "js"))
         (out-file (merge-pathnames* *js-dir* js-file)))
    (with-output-to-file (ps:*parenscript-stream* out-file :if-exists :supersede)
      (ps:ps-compile-file in-file))
    (beautify-js out-file)))

(defun browserify-vendor (output modules)
  (with-current-directory (*npm-dir*)
    (run-program
     (format nil "~A ~{ -r ~A ~} -o ~A" *browserify* modules output))))

(defun browserify-main (input output modules)
  (with-current-directory (*npm-dir*)
    (run-program
     (format nil "~A ~{ -x ~A ~} ~A -o ~A" *browserify* modules input output))))

(defvar *parenscript-watcher* nil)

(defun watching-parenscript-p ()
  (and *parenscript-watcher* (bt:thread-alive-p *parenscript-watcher*)))

;;;; Interface

(defun bundle-vendor ()
  "Bundle your node dependencies into *VENDOR-BUNDLE-FILE*.
Re-run only when npm update your deps."
  (browserify-vendor (merge-pathnames* *js-dir* *vendor-bundle-file*)
                     (node-dependencies)))

(defun bundle-main ()
  "Bundle your main JS file together with all your other JS files.
Usually called on your behalf by WATCH-PARENSCRIPT."
  (browserify-main
   (merge-pathnames* *js-dir* *main-file*)
   (merge-pathnames* *js-dir* *main-bundle-file*)
   (node-dependencies)))

(defun minify-js (js-file)
  "JS Minify JS-FILE to <file>.min.js and produce a source map
<file>.min.js.map"
  (let ((min-file (replace-file-extension js-file "min.js"))
        (map-file (replace-file-extension js-file "min.js.map")))
    (with-current-directory (*js-dir*)
      (run-program
       (format nil "~A ~A  --source-map ~A -o ~A"
               *uglifyjs* js-file map-file min-file)))))

(defun watch-parenscript ()
  "Watch the *PS-DIR* for changes to files and automatically compile
to JavaScript and run BUNDLE-MAIN."
  (when (watching-parenscript-p)
    (unwatch-parenscript))
  (open-fsnotify)
  (add-watch *ps-dir*)
  (setf *parenscript-watcher*
        (bt:make-thread (lambda ()
                          (loop
                            (sleep *sleep-time*)
                            (when-let (events (get-events))
                              (dolist (cons events)
                                (destructuring-bind (file . event) cons
                                  (when (eq :modify event)
                                    (handler-case
                                        (let ((name (file-namestring file)))
                                          (ps2js-file name)
                                          (bundle-main)
                                          (log:info "Done ~A" name))
                                      (error (e)
                                        (log:error "Error: ~A" e)))))))))
                        :name "Parenscript watcher")))

(defun unwatch-parenscript ()
  (bt:destroy-thread *parenscript-watcher*))
