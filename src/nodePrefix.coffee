clc = require 'cli-color'

# Log level stuff
LOG_PREFIX = 'MADEYE_LOGLEVEL'
__baseLogLevel = process.env[LOG_PREFIX] || 'info'
__specificLogLevels = {}
for k,v of process.env
  continue unless k.indexOf("#{LOG_PREFIX}_") == 0
  continue if k == LOG_PREFIX
  name = k.substr "#{LOG_PREFIX}_".length
  name = name.split('_').join(':')
  specificLogLevels[name] = v
