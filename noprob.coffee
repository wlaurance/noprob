# can be interactive
	# e.g. typing q could quit (killing processes
		# and informing of anything hanging)
# can have global and local commands
	# global commands would get run whenever anything changes
	# local commands would get run specifically on
		# whatever changed

_       = require 'underscore'
_.str   = require 'underscore.string'
program = require 'commander'
colors  = require 'colors'
fs      = require 'fs'
{exec}  = require 'child_process'
watch   = require 'watch'


class App
	constructor: ->
		program.option('-x --exec [command]', 'command to execute on change', '')
		.parse(process.argv)
		
		console.log program.exec
		
		@watchDir = '.'
		@pollInterval = 500
		
		@lastTime = @currentTime()
		
		if process.platform == 'darwin'
			@setDarwinWatcher()
		else if not fs.watch?
			@setWatchWatcher()
		else
			@setNodeFsWatcher()
		
		@run()

	currentTime: ->
		Math.round(new Date().getTime() / 1000)
		
	setDarwinWatcher: ->
		@watcher = (cb) =>
			piper = exec "find -L #{@watchDir} -type f -mtime -#{@currentTime() - @lastTime}s -print"
			
			piper.stderr.on 'data', (data) =>
				return process.stderr.write data.toString()
			
			piper.stdout.on 'data', (data) =>
				files = _.str.words data, '\n'
				for file in files
					cb(file)
				# add one to the time to prevent repeat reporting
				@lastTime = @currentTime() + 1
			
			piper.on 'exit', (code) =>
				setTimeout (=> @watcher(cb)), @pollInterval
			
	setWatchWatcher: ->
		@watcher = (cb) =>
			watch.watchTree @watchDir, (file, curr, prev) =>
				if prev? and curr.nlink != 0
					cb(file)
							
	setNodeFsWatcher: ->
		@watcher = (cb) =>
			fs.watch @watchDir, (e, file) =>
				if e == 'change'
					cb(file)
					
	run: ->
		@watcher (file) =>
			console.log "* Change detected.".green.bold
			console.log "No prob, I'll take care of that...".green.italic

app = new App()