// Generated by CoffeeScript 1.3.3
(function() {
  var App, app, colors, exec, fs, program, watch, _;

  _ = require('underscore');

  _.str = require('underscore.string');

  program = require('commander');

  colors = require('colors');

  fs = require('fs');

  exec = require('child_process').exec;

  watch = require('watch');

  App = (function() {

    function App() {
      program.option('-x, --exec [command]', 'string to execute globally on any file change', '').option('-l, --local [command]', "string to execute locally on any file that's changed", '').option('-w, --watch [directory]', 'directory to watch', '.').option('-e, --extension [extensions]', 'list of file extensions to watch', '').option('-d, --dot', 'watch hidden dot files').parse(process.argv);
      this.extensions = _.str.words(program.extension, '|');
      this.pollInterval = 500;
      this.lastTime = this.currentTime();
      if (process.platform === 'darwin') {
        this.setDarwinWatcher();
      } else if (!(fs.watch != null)) {
        this.setWatchWatcher();
      } else {
        this.setNodeFsWatcher();
      }
      this.run();
    }

    App.prototype.currentTime = function() {
      return Math.round(new Date().getTime() / 1000);
    };

    App.prototype.setDarwinWatcher = function() {
      var repeatCheck,
        _this = this;
      repeatCheck = {};
      return this.watcher = function(cb) {
        var piper;
        piper = exec("find -L " + program.watch + " -type f -mtime -" + (_this.currentTime() - _this.lastTime) + "s -print");
        piper.stderr.on('data', function(data) {
          return process.stderr.write(data.toString());
        });
        piper.stdout.on('data', function(data) {
          var file, files, stats, _i, _len, _results;
          _this.lastTime = _this.currentTime();
          files = _.str.words(data, '\n');
          _results = [];
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            file = files[_i];
            stats = fs.statSync(file);
            if (!(repeatCheck[file] != null) || repeatCheck[file].getTime() !== stats.mtime.getTime()) {
              repeatCheck[file] = stats.mtime;
              _results.push(cb(file));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
        return piper.on('exit', function(code) {
          return setTimeout((function() {
            return _this.watcher(cb);
          }), _this.pollInterval);
        });
      };
    };

    App.prototype.setWatchWatcher = function() {
      var _this = this;
      return this.watcher = function(cb) {
        return watch.watchTree(program.watch, function(file, curr, prev) {
          if ((prev != null) && curr.nlink !== 0) {
            return cb(file);
          }
        });
      };
    };

    App.prototype.setNodeFsWatcher = function() {
      var _this = this;
      return this.watcher = function(cb) {
        return fs.watch(program.watch, function(e, file) {
          if (e === 'change') {
            return cb(file);
          }
        });
      };
    };

    App.prototype.hasDotFile = function(path, fileName) {
      if (fileName[0] === '.' || path[0] === '.' || path.indexOf('/.') !== -1) {
        return true;
      }
      return false;
    };

    App.prototype.parsePath = function(path) {
      var cleanPath, extension, fileName;
      if (path.slice(0, 2) === './') {
        cleanPath = path.slice(2);
      }
      cleanPath = cleanPath.replace(/\ /g, '\\ ');
      fileName = cleanPath.slice(cleanPath.lastIndexOf('/') + 1);
      extension = fileName.slice(fileName.lastIndexOf('.') + 1);
      if (extension === fileName) {
        extension = '';
      }
      return [cleanPath, fileName, extension];
    };

    App.prototype.execAndPipe = function(command) {
      var piper,
        _this = this;
      piper = exec(command);
      piper.stderr.on('data', function(data) {
        console.log('');
        console.log("[noprob] Error detected.".red.bold);
        process.stdout.write(data);
        console.log('');
        return console.log("[noprob] No worries, I'll wait until you've changed something...".red.italic);
      });
      piper.stdout.on('data', function(data) {
        return process.stdout.write(data);
      });
      piper.on('exit', function(code) {
        return piper.dead = true;
      });
      return piper;
    };

    App.prototype.takeCareOfIt = function(what) {
      console.log("[noprob] No prob, I'll take care of that...".green.italic);
      return console.log(("[noprob] Executing '" + what + "'").green);
    };

    App.prototype.run = function() {
      var gPiper, gRelease, lPipers,
        _this = this;
      console.log('[noprob] Watching for changes...'.green.bold);
      gPiper = this.execAndPipe(program.exec);
      gRelease = this.currentTime() + 1;
      lPipers = {};
      return this.watcher(function(file) {
        var cleanPath, extension, fileName, tempCmd, _ref, _ref1;
        _ref = _this.parsePath(file), cleanPath = _ref[0], fileName = _ref[1], extension = _ref[2];
        if (_this.extensions.indexOf(extension) === -1 && program.extension !== '') {
          return;
        }
        if (!program.dot && _this.hasDotFile(cleanPath, fileName)) {
          return;
        }
        console.log(("[noprob] Change detected in " + fileName + ".").green.bold);
        process.nextTick(function() {
          var path, piper, _results;
          _results = [];
          for (path in lPipers) {
            piper = lPipers[path];
            if (piper.dead) {
              _results.push(lPipers[path] = null);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
        if (program.exec !== '') {
          if (_this.currentTime() > gRelease) {
            gRelease = _this.currentTime + 1;
            _this.takeCareOfIt(program.exec);
            if (gPiper != null) {
              gPiper.kill();
            }
            gPiper = _this.execAndPipe(program.exec);
          }
        }
        if (program.local !== '') {
          tempCmd = program.local.replace('<file>', cleanPath);
          _this.takeCareOfIt(tempCmd);
          if ((_ref1 = lPipers[cleanPath]) != null) {
            _ref1.kill();
          }
          return lPipers[cleanPath] = _this.execAndPipe(tempCmd);
        }
      });
    };

    return App;

  })();

  app = new App();

}).call(this);
