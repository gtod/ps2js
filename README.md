PS2JS
==========

A trivial Common Lisp library to watch a directory containing
[Parenscript](https://github.com/vsedach/Parenscript) source
files and compile (and bundle) those to JavaScript.

## Dependencies

Node.js and [npm](https://www.npmjs.com/).  We use npm installed
libraries to bundle a "vendor.js" of all the JavaScript dependencies
of your own Parenscript project.

We also need the following npm modlues/tools:

[Browserify](http://browserify.org/),
[js-beautify](https://github.com/beautify-web/js-beautify) and
[UglifyJS](https://github.com/mishoo/UglifyJS2) as command line apps.
For example `sudo npm install uglify-js -g`.
