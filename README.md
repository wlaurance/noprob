Noprob
====
Simple file change monitoring for any kind of development.

* [Why?](#a)
* [Installation](#b)
* [Options](#c)

<a name='a' />
Why?
----
Having a utility that can restart or recompile or reconfigure or re*whatever* whenever you change a file can be incredibly convenient.  Many programs of this sort are geared to work with a specific toolchain or tend to be overly complicated for what should be a simple task.

No worries.  Noprob's got your back, no problem.

<a name='b' />
Installation
----
[Install npm.](http://nodejs.org/#download) (it comes with Node.js).

Run: `$ sudo npm -g install noprob`

<a name='c' />
Options
----
* -h, --help
	* output usage information
* -x, --exec [command]
	* string to execute globally on any file change
* -l, --local [command]
	* string to execute locally on any file that's changed
* -w, --watch [directory]
	* directory to watch
* -e, --extension [extensions]
	* list of file extensions to watch
* -d, --dot
	* watch hidden dot files
