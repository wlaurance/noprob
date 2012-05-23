// Generated by CoffeeScript 1.3.3
(function() {
  var Api, noprob, program,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  program = require('commander');

  noprob = require('./noprob');

  Api = (function(_super) {

    __extends(Api, _super);

    function Api() {
      this.doAction = __bind(this.doAction, this);

      this.setAction = __bind(this.setAction, this);
      this.commandLine();
      this.extras();
      this.setWatcher();
    }

    Api.prototype.setAction = function(client_action) {
      this.client_action = client_action;
      if (typeof this.client_action !== 'function') {
        throw new Error('Supplied argument is not of type function');
      }
    };

    Api.prototype.doAction = function(cleanPath) {
      try {
        return this.client_action(cleanPath);
      } catch (e) {
        throw new Error('No client_action provided');
      }
    };

    Api.prototype.setWatchDirectory = function(dir) {
      return program.watch = dir;
    };

    return Api;

  })(noprob);

  module.exports = Api;

}).call(this);
