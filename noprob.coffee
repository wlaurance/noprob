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


execAndPipe = (execString) ->
	piper = exec execString

	piper.stderr.on 'data', (data) ->
		# console.log "** #{execString} error **"
		process.stderr.write data.toString()
	piper.stdout.on 'data', (data) ->
		# console.log "-- #{execString} --"
		process.stdout.write data.toString()

currentTime = ->
	Math.round(new Date().getTime() / 1000)	


exports.run = () ->
	watchDir = '.'
	pollInterval = 500
	
	lastTime = currentTime()
	
	if process.platform == 'darwin' #and false
		watcher = (cb) ->
			piper = exec "find -L #{watchDir} -type f -mtime -#{currentTime() - lastTime}s -print"
			
			piper.stderr.on 'data', (data) ->
				return process.stderr.write data.toString()
			
			piper.stdout.on 'data', (data) ->
				files = _.str.words data, '\n'
				for file in files
					cb(file)
				# add one to the time to prevent repeat reporting
				lastTime = currentTime() + 1
			
			piper.on 'exit', (code) ->
				setTimeout (-> watcher(cb)), pollInterval
		
	else if not fs.watch? #or true
		watcher = (cb) ->
			watch.watchTree watchDir, (file, curr, prev) ->
				if prev? and curr.nlink != 0
					cb(file)
						
	else
		watcher = (cb) ->
			fs.watch watchDir, (e, file) ->
				if e == 'change'
					cb(file)
					
		
		
	watcher (file) ->
		console.log "* Change detected.".green.bold
		console.log "No prob, I'll take care of that...".green.italic
		