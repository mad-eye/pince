# This is a simple port of microevent.js to Coffeescript. I've changed the
# function names to be consistent with node.js EventEmitter.
#
# microevent.js is copyright Jerome Etienne, and licensed under the MIT license:
# https://github.com/jeromeetienne/microevent.js
# Initial conversion to Coffeescript was done by Joseph Gentle in ShareJS
# https://github.com/share/ShareJS

nextTick = if process?.nextTick? then process.nextTick else (fn) -> setTimeout fn, 0

class MicroEvent
  on: (event, fct) ->
    @_events ||= {}
    @_events[event] ||= []
    @_events[event].push(fct)
    this

  removeListener: (event, fct) ->
    @_events ||= {}
    listeners = (@_events[event] ||= [])
    
    # Sadly, there's no IE8- support for indexOf.
    i = 0
    while i < listeners.length
      listeners[i] = undefined if listeners[i] == fct
      i++

    nextTick => @_events[event] = (x for x in @_events[event] when x)

    this

  emit: (event, args...) ->
    return this unless @_events?[event]
    fn.apply this, args for fn in @_events[event] when fn
    this

# mixin will delegate all MicroEvent.js function in the destination object
MicroEvent.mixin = (obj) ->
  proto = obj.prototype || obj

  # Damn closure compiler :/
  proto.on = MicroEvent.prototype.on
  proto.removeListener = MicroEvent.prototype.removeListener
  proto.emit = MicroEvent.prototype.emit
  obj

isBrowser = 'undefined' != typeof window
isMeteor = 'undefined' != typeof Meteor
if isBrowser || isMeteor
  @MicroEvent = MicroEvent
else
  module.exports = MicroEvent


