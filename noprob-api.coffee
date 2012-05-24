program = require 'commander'
noprob = require './noprob'
class Api extends noprob
  constructor:()->
    @commandLine()
    @extras()
    @setWatcher()

  setAction:(@client_action)=>
    throw new Error 'Supplied argument is not of type function' if typeof @client_action isnt 'function'

  doAction:(cleanPath)=>
    if @client_action?
      @client_action cleanPath
    else
      throw new Error 'No client_action provided'

  setWatchDirectory:(dir)->
    program.watch = dir
module.exports = Api
