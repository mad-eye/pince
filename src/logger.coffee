isMeteor = 'undefined' != typeof Meteor
isBrowser = 'undefined' != typeof window

if isBrowser
  moment = (date) -> moment
  moment.format = (format) -> ""
  EventEmitter = MicroEvent
else #isServer
  if isMeteor
    moment = Npm.require 'moment'
    {EventEmitter} = Npm.require 'events'
  else
    moment = require 'moment'
    {EventEmitter} = require 'events'

__levelnums =
  error: 0
  warn: 1
  info: 2
  debug: 3
  trace: 4

noop = (x) -> x
if isBrowser
  colors =
    error: noop
    warn: noop
    info: noop
    debug: noop
    trace: noop
else
  if isMeteor
    clc = Npm.require 'cli-color'
  else
    clc = require 'cli-color'

  colors =
    error: clc.red.bold
    warn: clc.yellow
    info: clc.bold
    debug: clc.blue
    trace: clc.blackBright

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
  console.log "SpecificLogLevels:", specificLogLevels
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
    @logLevels = {}
    #remember loggers for changing levels later
    @loggers = {}
    # Need to remember these to detach
    # name: {level: fn}
    @listenFns = {}

  #setLevel(level) sets the global default level
  #setLevel(name, level) sets the level for name
  setLevel: (level) ->
    if arguments[1]
      #setLevel(name, level)
      name = arguments[0]
      level = arguments[1]
      throw new Error 'Must supply a name' unless name

      levels = {}
      levels[name] = level
      @setLevels levels
      return

    throw new Error 'Must supply a level' unless level
    return if __loggerLevel == level
    oldLevel = __loggerLevel
    __loggerLevel = level

    #recalculate how we listen to listeners and loggers
    for name, logger of @loggers
      thisLevel = @logLevels[name]
      if thisLevel
        #No need to recaculate if the loggers level is above or below
        #both oldLevel and the new level
        unless level < thisLevel < oldLevel or oldLevel < thisLevel < level
          continue

      @detach name
      @listen logger, name, thisLevel
    return

  #levels is an object {name:level} which sets each name to level
  setLevels: (levels) ->
    for name, level of levels
      oldLevel = @logLevels[name]
      return if level == oldLevel
      logger = @loggers[name]
      @detach name
      @listen logger, name, level

  listen: (logger, name, level=null) ->
    unless logger
      throw Error "An object is required for logging!"
    unless name
      throw Error "Name is required for logging!"
    @loggers[name] = logger
    @logLevels[name] = level if level

    level ?= __specificLoggerLevels[name]
    level ?= __loggerLevel
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
    delete @logLevels[name]
    return
  
  handleLog: (data) ->
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
      console.error.apply console, messages
    else
      console.log.apply console, messages

listener = new Listener()

class @Logger extends EventEmitter
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = name: options
    @name = options.name
    listener.listen this, options.name, options.logLevel

  @setLevel: (level) ->
    listener.setLevel level

  @setLevels: (name, level) ->
    listener.setLevels name, level

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

Logger.listener = listener
unless typeof exports == "undefined"
  module.exports = Logger
