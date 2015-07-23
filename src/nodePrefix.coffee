clc = require 'cli-color'
moment = require 'moment'
{EventEmitter} = require 'events'

# Log level stuff
LOG_PREFIX = 'MADEYE_LOGLEVEL'
defaultLogLevel = process.env[LOG_PREFIX]
specificLogLevels = {}
for k,v of process.env
  continue unless k.indexOf("#{LOG_PREFIX}_") == 0
  continue if k == LOG_PREFIX
  name = k.substr "#{LOG_PREFIX}_".length
  name = name.split('_').join(':')
  specificLogLevels[name] = v
