(defpackage :ps2js
  (:use #:cl
        #:uiop/pathname
        #:uiop/filesystem
        #:uiop/run-program
        #:cl-fsnotify
        #:alexandria)
  ;;; You are probably best off using package qualified names rather
  ;;; than importing all of this mess...
  (:export #:*ps-dir*
           #:*js-dir*
           #:*main-file*
           #:*npm-dir*
           #:*node-dependencies*
           #:*browserify*
           #:*uglifyjs*
           #:*js-beautify-cmd*
           #:*vendor-bundle-file*
           #:*main-bundle-file*
           #:*sleep-time*
           #:bundle-vendor
           #:bundle-main
           #:minify-js
           #:watch-parenscript
           #:unwatch-parenscript)
  (:documentation "Automatically compile Parenscript files to
JavaScript and bundle."))
