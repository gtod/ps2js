(asdf:defsystem ps2js
  :author "Gregory Tod <lisp@gtod.net>"
  :version "0.1.0"
  :license "MIT"
  :description "An auto compiler and bundler for Parenscript files"
  :depends-on (#:parenscript
               #:alexandria
               #:cl-ppcre
               #:bordeaux-threads
               #:uiop/pathname
               #:uiop/filesystem
               #:uiop/run-program
               #:log4cl
               #:yason
               #:cl-fsnotify)
  :serial t
  :components ((:file "package")
               (:file "ps2js")))
