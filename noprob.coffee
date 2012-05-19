# can be interactive
	# e.g. typing q could quit (killing processes
		# and informing of anything hanging)
# can have global and local commands
	# global commands would get run whenever anything changes
	# local commands would get run specifically on
		# whatever changed

_      = require 'underscore'
_.str  = require 'underscore.string'
fs     = require 'fs'
{exec} = require 'child_process'


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
	lastTime = currentTime()
	
	if process.platform == 'darwin'
		watcher = (cb) ->
			piper = exec "find -L . -type f -mtime -#{currentTime() - lastTime}s -print"
			
			piper.stderr.on 'data', (data) ->
				process.stderr.write data.toString()
			
			piper.stdout.on 'data', (data) ->
				files = _.str.words data, '\n'
				cb(files)
				# add one to the time to prevent repeat reporting
				lastTime = currentTime() + 1
			
			piper.on 'exit', (code) ->
				setTimeout (-> watcher(cb)), 500
		
	else if not fs.watch?
		console.log 'ass'
		
		
	watcher (files) ->
		console.log files
		