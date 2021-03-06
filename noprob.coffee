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
    .option('-x, --exec [command]', 'string to execute globally on any file change', '')
    .option('-l, --local [command]', "string to execute locally on any file that's changed", '')
    .option('-w, --watch [directory]', 'directory to watch', '.')
    .option('-e, --extension [extensions]', 'list of file extensions to watch', '')
    .option('-d, --dot', 'watch hidden dot files')
    .parse(process.argv)
    
    @extensions = _.str.words program.extension, '|'
    @pollInterval = 500
    @lastTime = @currentTime()
    
    # releases keep commands and logs from getting printed over and over
    # when there is a sudden influx of changes or messages
    @gRelease = @currentTime() + 1
    @errRelease = @currentTime()
    
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
    repeatCheck = {}
    @watcher = (cb) =>
      piper = exec "find -L #{program.watch} -type f -mtime -#{@currentTime() - @lastTime}s -print"
      
      piper.stderr.on 'data', (data) =>
        return process.stderr.write data.toString()
      
      piper.stdout.on 'data', (data) =>
        @lastTime = @currentTime()
        files = _.str.words data, '\n'
        for file in files
          # prevent repeat reporting
          stats = fs.statSync file
          if not repeatCheck[file]? or repeatCheck[file].getTime() != stats.mtime.getTime()
            repeatCheck[file] = stats.mtime
            cb(file)
      
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
        if e == 'change' or e == 'rename'
          cb(file)
          
  hasDotFile: (path, fileName) ->
    if fileName[0] == '.' or path[0] == '.' or path.indexOf('/.') != -1
      return true
    false
          
  parsePath: (path) ->
    cleanPath = path
    cleanPath = path[2..] unless path[0..1] != './'
    cleanPath = cleanPath.replace /\ /g, '\\ '
    fileName = cleanPath[cleanPath.lastIndexOf('/')+1..]
    extension = fileName[fileName.lastIndexOf('.')+1..]
    if extension == fileName then extension = ''
    return [cleanPath, fileName, extension]
    
  execAndPipe: (command) ->
    piper = exec command
    
    piper.stderr.on 'data', (data) =>
      if @currentTime() > @errRelease
        @errRelease = @currentTime() + 1
        console.log ''
        console.log "[noprob] Error detected.".red.bold
        console.log "[noprob] No worries, I'll wait until you've changed something...".red.italic
      process.stdout.write data
      
    piper.stdout.on 'data', (data) =>
      process.stdout.write data
      
    piper.on 'exit', (code) =>
      piper.dead = true
      
    return piper
    
  takeCareOfIt: (what) ->
    console.log "[noprob] No prob, I'll take care of that...".green.italic
    console.log "[noprob] Executing '#{what}'".green
          
  run: ->
    console.log '[noprob] Watching for changes...'.green.bold
    
    gPiper = @execAndPipe program.exec
    lPipers = {}
    @watcher (file) =>
      [cleanPath, fileName, extension] = @parsePath file
      if @extensions.indexOf(extension) == -1 and program.extension != '' then return
      if not program.dot and @hasDotFile(cleanPath, fileName) then return
      # console.log cleanPath
      # console.log fileName
      # console.log extension
      
      console.log "[noprob] Change detected in #{fileName}.".green.bold
      
      # clean up dead pipes
      # process.nextTick ->
      #   for path,piper of lPipers
      #     if piper?.dead then lPipers[path] = null
        
      if program.exec != ''
        if @currentTime() > @gRelease
          @gRelease = @currentTime() + 1
          @takeCareOfIt program.exec
          gPiper?.kill()
          gPiper = @execAndPipe program.exec
      if program.local != ''
        tempCmd = program.local.replace('<file>', cleanPath)
        @takeCareOfIt tempCmd
        lPipers[cleanPath]?.kill()
        lPipers[cleanPath] = @execAndPipe tempCmd
      

app = new App()
