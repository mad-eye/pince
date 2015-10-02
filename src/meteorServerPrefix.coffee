clc = Npm.require 'cli-color'

__baseLogLevel = Meteor.settings?.public?.logLevel ? 'info'
__specificLogLevels =  Meteor.settings?.public?.specificLogLevels ? {}
