isMeteor = 'undefined' != typeof Meteor
isBrowser = 'undefined' != typeof window

# Man, importing things in CS in Meteor is a PITA
# moment
if isMeteor
  moment = Package['momentjs:moment'].moment
else if isBrowser
  # TODO: Import moment for non-Meteor browsers
  moment = (date) -> moment
  moment.format = (format) -> ""
else # node
  moment = require 'moment'

if isBrowser
  EventEmitter = MicroEvent
else #isServer
  if isMeteor
    {EventEmitter} = Npm.require 'events'
    ConsoleOutput = share.ConsoleOutput
  else
    {EventEmitter} = require 'events'
    ConsoleOutput = require './consoleOutput'

__extend = (obj, others...) ->
  for o in others
    for own k, v of o
      obj[k] = v
  return obj

__levelnums =
  error: 0
  warn: 1
  info: 2
  debug: 3
  trace: 4


LOG_PREFIX = 'MADEYE_LOGLEVEL'
parseDefaultLogLevel = ->
  if isBrowser
    if isMeteor
      defaultLogLevel = Meteor.settings?.public?.logLevel
    else
      defaultLogLevel = null
  else
    defaultLogLevel = process.env[LOG_PREFIX]
  return defaultLogLevel

parseSpecificLogLevels = ->
  if isBrowser
    if isMeteor
      return Meteor.settings?.public?.specificLogLevels ? {}
    else
      return {}

  specificLogLevels = {}
  for k,v of process.env
    continue unless k.indexOf("#{LOG_PREFIX}_") == 0
    continue if k == LOG_PREFIX
    name = k.substr "#{LOG_PREFIX}_".length
    name = name.split('_').join(':')
    specificLogLevels[name] = v
  return specificLogLevels


__loggerLevel = parseDefaultLogLevel() ? 'info'
__specificLoggerLevels = parseSpecificLogLevels()

__onError = null

class Listener
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = logLevel: options
    #Default logLevel
    @logLevel = options.logLevel ? __loggerLevel
    #logLevels for specific loggers
    @logLevels = options.logLevels ? __specificLoggerLevels
    #remember loggers for changing levels later
    @loggers = {}
    # Need to remember these to detach
    # name: {level: fn}
    @listenFns = {}
    if isBrowser
      @_output = share.BrowserOutput.output
      @__err = share.BrowserOutput.__err
      @__out = share.BrowserOutput.__out
    else
      @_output = ConsoleOutput.output

  _reattachLoggers: ->
    #recalculate how we listen to listeners and loggers
    for name, logger of @loggers
      @detach name
      @listen logger, name

  #setLevel(level) sets the global default level
  #setLevel(name, level) sets the level for name
  setLevel: (name, level) ->
    #setLevel(name, level)
    if level
      throw new Error 'Must supply a name' unless name

      levels = {}
      levels[name] = level
      @setLevels levels
      return

    #setLevel(level)
    level = name
    throw new Error 'Must supply a level' unless level
    return if @logLevel == level
    @logLevel = level
    @_reattachLoggers()
    return

  #levels is an object {name:level} which sets each name to level
  setLevels: (levels) ->
    for name, level of levels
      @logLevels[name] = level
    @_reattachLoggers()
    return

  #Check first for any specific levels
  findLevelFor: (name) ->
    level = @logLevels[name]

    #Check hierarchically up the : chain
    parentName = name
    while (parentName.indexOf(':') > -1) and not level
      lastIdx = parentName.lastIndexOf(':')
      parentName = parentName.substr 0, lastIdx
      parentLevel = @logLevels[parentName]
      level ?= parentLevel
      break if level


    level ?= @logLevel
    return level

  listen: (logger, name) ->
    unless logger
      throw Error "An object is required for logging!"
    unless name
      throw Error "Name is required for logging!"
    @loggers[name] = logger
    @logLevels[name] = level if level

    level = @findLevelFor name

    #TODO: Detach possibly existing logger
    @listenFns[name] = {}

    errorFn = (msgs...) =>
      shouldPrint = __onError? msgs
      #Be explicit about false, to not trigger on undefined/null
      unless shouldPrint == false
        @handleLog timestamp: new Date, level:'error', name:name, message:msgs
    logger.on 'error', errorFn
    @listenFns[name]['error'] = errorFn

    ['warn', 'info', 'debug', 'trace'].forEach (l) =>
      return if __levelnums[l] > __levelnums[level]
      listenFn = (msgs...) =>
        @handleLog timestamp: new Date, level:l, name:name, message:msgs
      logger.on l, listenFn
      @listenFns[name][l] = listenFn
    return

  detach: (name) ->
    logger = @loggers[name]
    return unless logger
    for level, listenFn of @listenFns[name]
      logger.removeListener level, listenFn
    delete @listenFns[name]
    delete @loggers[name]
    #delete @logLevels[name]
    return

  handleLog: (data) ->
    if isBrowser
      timestr = moment(data.timestamp).format("HH:mm:ss.SSS")
    else
      timestr = moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss.SSS")

    color = colors[data.level]
    prefix = "#{timestr} #{color(data.level+": ")} "
    prefix += "[#{data.name}] " if data.name

    if 'string' == typeof data.message
      messages = [data.message]
    else
      messages = data.message

    messages.unshift prefix

    if __levelnums[data.level] <= __levelnums['warn']
      Pince.err messages
    else
      Pince.out messages

listener = new Listener()

class Logger extends EventEmitter
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = name: options
    @name = options.name
    listener.listen this, options.name, options.logLevel

  @setLevel: (level) ->
    listener.setLevel.apply listener, arguments

  @setLevels: (levels) ->
    listener.setLevels.apply listener, arguments

  @onError: (callback) ->
    __onError = callback

  @listen: (logger, name, level) ->
    listener.listen logger, name, level

  #take single message arg, that is an array.
  _log: (level, messages) ->
    messages.unshift level
    @emit.apply this, messages

  #take multiple args
  log: (level, messages...) -> @_log level, messages

  trace: (messages...) -> @_log 'trace', messages
  debug: (messages...) -> @_log 'debug', messages
  info: (messages...) -> @_log 'info', messages
  warn: (messages...) -> @_log 'warn', messages
  error: (messages...) -> @_log 'error', messages

@Logger = Logger
Logger.listener = listener
unless typeof exports == "undefined"
  module.exports = Logger
