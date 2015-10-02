
## Formatting

if typeof window != 'undefined'
  noop = (x) -> x
  colors =
    error: noop
    warn: noop
    info: noop
    debug: noop
    trace: noop
else
  colors =
    error: clc.red.bold
    warn: clc.yellow
    info: clc.bold
    debug: clc.blue
    trace: clc.blackBright

# Pad integer d to n places with preceding 0s
pad = (d, n) ->
  d = d.toString()
  while d.length < n
    d = '0' + d
  return d

# Map token to replacement values from date d
__dateFormatStr = "YYYY-MM-DD HH:mm:ss.SSS"

__dateFormatTokens =
  'YYYY': (d) -> pad(d.getFullYear(), 4)
  'MM': (d) -> pad(d.getMonth(), 2)
  'DD': (d) -> pad(d.getDate(), 2)
  'HH': (d) -> pad(d.getHours(), 2)
  'mm': (d) -> pad(d.getMinutes(), 2)
  'ss': (d) -> pad(d.getSeconds(), 2)
  'SSS': (d) -> pad(d.getMilliseconds(), 3)

formatDate = (date, formatStr=__dateFormatStr) ->
  str = formatStr
  for token, valueFn of __dateFormatTokens
    value = valueFn date
    str = str.replace(token, value)
  return str

__formatStr = "%T %L:  [%N]  %M"

__formatTokens =
  '%T': (data) -> data.formattedTimestamp
  '%L': (data) -> colors[data.level](data.level)
  '%N': (data) -> data.name
  '%M': (data) -> data.messages[0]

formatLog = (data, formatStr=__formatStr) ->
  str = formatStr
  for token, valueFn of __formatTokens
    value = valueFn data
    str = str.replace(token, value)
  output = data.messages[1..]
  output.unshift(str)
  return output


## END Formatting

__levels = ['error', 'warn', 'info', 'debug', 'trace']
__levelnums = {}
__levelnums[l] = i for l, i in __levels

findLevelFor = (name) ->
  #Check first for any specific levels
  level = __specificLogLevels[name]

  #Check hierarchically up the : chain
  parentName = name
  while (parentName.indexOf(':') > -1) and not level?
    lastIdx = parentName.lastIndexOf(':')
    parentName = parentName.substr 0, lastIdx
    level ?= __specificLogLevels[parentName]

  level ?= __baseLogLevel
  return level

shouldLog = (name, level) ->
  allowedLevelNum = __levelnums[findLevelFor name]
  if __levelnums[level] > allowedLevelNum
    return false
  return true

class Logger
  # Class Methods
  @setLevel = (name, level) ->
    unless level
      level = name
      name = null

    unless level of __levelnums
      throw new Error("Level #{level} unknown.")

    if name
      __specificLogLevels[name] = level
    else
      __baseLogLevel = level

    return

  #levels is an object {name:level} which sets each name to level
  @setLevels: (levels) ->
    for name, level of levels
      __specificLogLevels[name] = level
    return

  @setDateFormat: (str) ->
    __dateFormatStr = str

  @setFormat: (str) ->
    __formatStr = str

  @_log = (data) ->
    return unless shouldLog data.name, data.level
    @_output data

  @_output = (data) ->
    # 2013-10-31 11:32:48.374 info:  [router]  Finally! Someone is
    data.formattedTimestamp = formatDate(data.timestamp, __dateFormatStr)
    output = formatLog(data, __formatStr)
    switch data.level
      when 'trace', 'debug' then fn = console.log
      when 'info' then fn = console.info ? console.log
      when 'warn' then fn = console.warn ? console.log
      when 'error' then fn = console.error ? console.log
    fn.apply console, output

  # Instance Methods
  constructor: (@name) ->

  trace: (messages...) -> @log 'trace', messages
  debug: (messages...) -> @log 'debug', messages
  info: (messages...) -> @log 'info', messages
  warn: (messages...) -> @log 'warn', messages
  error: (messages...) -> @log 'error', messages

  # log takes messages as an array.  It will ignore additional arguments.
  log: (level, messages) ->
    unless Array.isArray messages
      messages = [messages]

    data = {level, messages}
    data.name = @name
    data.timestamp = new Date()

    Logger._log data
