Noprob
====
Simple file change monitoring for any kind of development.

**Note:** Noprob has just been released and I haven't had the chance to test it on any system besides osx yet.  I'll get to it soon.

* [Why?](#a)
* [Installation](#b)
* [Options](#c)
* [Usage and Examples](#d)

<a name='a' />
Why?
----
Having a utility that can restart or recompile or reconfigure or re*whatever* whenever you change a file can be incredibly convenient.  Many programs of this sort are geared to work with a specific toolchain or tend to be overly complicated for what should be a simple task.

No worries.  Noprob's got your back, no problem.

<a name='b' />
Installation
----
[Install npm.](http://nodejs.org/#download) (it comes with Node.js).

Run: `$ npm -g install noprob`

<a name='c' />
Options
----
* -h, --help
	* Output usage information.
* -x, --exec [command]
	* String to execute globally on any file change.
	* You can wrap command strings in single `'` or double `"` quotes.
* -l, --local [command]
	* String to execute locally on any file that's changed.
	* Use `<file>` to mark where to insert the change file's name in the command string.
* -w, --watch [directory]
	* Directory to watch.
* -e, --extension [extensions]
	* List of file extensions to watch.
	* Wrap in single or double quotes and seperate extensions with a `|`.
* -d, --dot
	* Watch hidden dot files.
	* Files that begin with a '.' or that are in a folder that begins with a '.' are ignored by default.  Use this option to watch them.

<a name='d' />
Usage and Examples
----
There are two ways to execute commands in Noprob: globally and locally.

**Global** commands run once on noprob startup and then on every file change without worrying about specific files.  They are defined with `-x` or `--exec`.

Run and restart a node server on javascript source changes:
* `$ noprob -x 'node server.js' -e 'js'`

**Local** commands accept the `<file>` tag which will insert the changed file's name into the command.  They are defined with `-l` or `--local`.

Compile individual coffescript files in the "src" folder into javascript on demand (closely mimics coffescript's internal -w option):
* `$ noprob -l 'coffee -c <file>' -e 'coffee' -w src`

Copy changed files into a 'copies' folder one directory above the current one (we don't put it in a nested directory since noprob would try to copy new files it copies into there)
* `$ noprob -l 'cp <file> ../copies/'`