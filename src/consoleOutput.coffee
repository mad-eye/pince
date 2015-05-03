isMeteor = 'undefined' != typeof Meteor

#We are server-side, so we can make some assumptions.
if isMeteor
  clc = Npm.require 'cli-color'
  moment = Npm.require 'moment'
else
  clc = require 'cli-color'
  moment = require 'moment'

colors =
  error: clc.red.bold
  warn: clc.yellow
  info: clc.bold
  debug: clc.blue
  trace: clc.blackBright

ConsoleOutput =
  #data: {level, timestamp, [message], stderr:bool}
  output: (data) ->
    return unless data.message
    timestr = moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss.SSS")
    color = colors[data.level]
    prefix = "#{timestr} #{color(data.level+": ")} "
    prefix += "[#{data.name}] " if data.name

    if 'string' == typeof data.message
      messages = [data.message]
    else
      messages = data.message

    messages.unshift prefix

    if data.stderr
      console.error.apply(console, messages)
    else
      console.log.apply(console, messages)


if isMeteor
  share.ConsoleOutput = ConsoleOutput
else
  module.exports = ConsoleOutput
