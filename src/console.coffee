isBrowser = 'undefined' != typeof window
isMeteor = 'undefined' != typeof Meteor
Pince = {}

# Taken from meteor Meteor._debug
Pince._browserOut = ->
  #can't do much with very old browsers
  return unless console?.log?
  # IE Companion breaks otherwise
  # IE10 PP4 requires at least one argument
  return console.log('') if (arguments.length == 0)

  # IE doesn't have console.log.apply, it's not a real Object.
  # http:#stackoverflow.com/questions/5538972/console-log-apply-not-working-in-ie9
  # http:#patik.com/blog/complete-cross-browser-console-log/
  if (typeof console.log.apply == "function")
    # Most browsers
    console.log.apply(console, arguments)
  else if (typeof Function.prototype.bind == "function")
    # IE9
    log = Function.prototype.bind.call(console.log, console)
    log.apply(console, arguments)
  else
    # IE8
    Function.prototype.call.call(console.log, console, Array.prototype.slice.call(arguments))

Pince._browserErr = ->
  #can't do much with very old browsers
  return unless console?.error?
  # IE Companion breaks otherwise
  # IE10 PP4 requires at least one argument
  return console.error('') if (arguments.length == 0)

  # IE doesn't have console.log.apply, it's not a real Object.
  # http:#stackoverflow.com/questions/5538972/console-log-apply-not-working-in-ie9
  # http:#patik.com/blog/complete-cross-browser-console-log/
  if (typeof console.error.apply == "function")
    # Most browsers
    console.error.apply(console, arguments)
  else if (typeof Function.prototype.bind == "function")
    # IE9
    error = Function.prototype.bind.call(console.error, console)
    error.apply(console, arguments)
  else
    # IE8
    Function.prototype.call.call(console.error, console, Array.prototype.slice.call(arguments))

Pince.out = (messages) ->
  if (isBrowser)
    Pince._browserOut.apply(this, messages)
  else
    console.log.apply(console, messages)

Pince.err = (messages) ->
  if (isBrowser)
    Pince._browserOut.apply(this, messages)
  else
    console.error.apply(console, messages)

if isBrowser || isMeteor
  @Pince = Pince
else
  module.exports = Pince

