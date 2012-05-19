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
		program
		.option('-x --exec [command]', 'string to execute on change', '')
		.option('-w --watch [directory]', 'directory to watch', '.')
		.option('-d --dot', 'watch files the begin with a dot')
		.parse(process.argv)
		
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
			piper = exec "find -L #{program.watch} -type f -mtime -#{@currentTime() - @lastTime}s -print"
			
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
			watch.watchTree program.watch, (file, curr, prev) =>
				if prev? and curr.nlink != 0
					cb(file)
							
	setNodeFsWatcher: ->
		@watcher = (cb) =>
			fs.watch program.watch, (e, file) =>
				if e == 'change'
					cb(file)
					
	parsePath: (path) ->
		cleanPath = path[2..] unless path[0..1] != './'
		cleanPath = cleanPath.replace /\ /g, '\\ '
		fileName = cleanPath[cleanPath.lastIndexOf('/')+1..]
		extension = fileName[fileName.lastIndexOf('.')+1..]
		if extension == fileName then extension = ''
		return [cleanPath, fileName, extension]
					
	run: ->
		piper = null
		@watcher (file) =>
			[cleanPath, fileName, extension] = @parsePath file
			# console.log cleanPath
			# console.log fileName
			# console.log extension
			if not program.dot and fileName[0] == '.' then return
			
			console.log "* Change detected.".green.bold
			console.log "No prob, I'll take care of that...".green.italic
			console.log ''
			
			piper?.kill()
			piper = exec program.exec
			
			piper.stderr.on 'data', (data) =>
				console.log "* Error detected.".red.bold
				console.log ''
				console.log data
				console.log ''
				console.log "No worries, I'll wait until you've changed something...".green.italic
				
			piper.stdout.on 'data', (data) =>
				console.log data

app = new App()