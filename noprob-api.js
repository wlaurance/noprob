// Generated by CoffeeScript 1.3.3
(function() {
  var Api, noprob,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  noprob = require('./noprob');

  Api = (function(_super) {

    __extends(Api, _super);

    function Api() {
      this.setWatcher();
    }

    return Api;

  })(noprob);

  module.exports = Api;

}).call(this);
