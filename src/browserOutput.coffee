# We are in the browser, so we can assume certain things
isMeteor = 'undefined' != typeof Meteor

colors =
  error: 'color: red; font-weight: bold;'
  warn: 'color: orange;'
  info: 'font-weight: bold;'
  debug: 'color: blue;'
  trace: 'color: grey;'

BrowserOutput =
  #data: {level, timestamp, [message], stderr:bool}
  output: (data) ->
    #can't do much with very old browsers
    return unless console?.log?
    return unless data.message

    if 'string' == typeof data.message
      messages = [data.message]
    else
      messages = data.message

    messages.unshift "[#{data.name}]" if data.name

    #Add level
    #TODO: Add timestamp if supplied. Use moment on the browser?
    if true #TODO: Should check for browser color support
      messages.unshift colors[data.level]
      messages.unshift "%c#{data.level}:"
    else
      messages.unshift "#{data.level}:"

    if data.stderr
      __err.apply this, messages
    else
      __out.apply this, messages

# Taken from meteor Meteor._debug
BrowserOutput.__out = __out = ->
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

BrowserOutput.__err = __err = ->
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

if isMeteor
  share.BrowserOutput = BrowserOutput
else
  @share ?= {}
  share.BrowserOutput = BrowserOutput
