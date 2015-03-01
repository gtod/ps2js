(defpackage :ps2js
  (:use #:cl
        #:uiop/pathname
        #:uiop/filesystem
        #:uiop/run-program
        #:cl-fsnotify
        #:alexandria)
  (:export #:bundle-vendor
           #:bundle-main
           #:minify-js
           #:watch-parenscript
           #:unwatch-parenscript)
  (:documentation "Automatically compile Parenscript files to
JavaScript and bundle."))
