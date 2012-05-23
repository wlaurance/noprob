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
    try
      @client_action cleanPath
    catch e
      throw new Error 'No client_action provided'

  setWatchDirectory:(dir)->
    program.watch = dir
module.exports = Api
