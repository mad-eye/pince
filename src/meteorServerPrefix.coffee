moment = Package['momentjs:moment'].moment
{EventEmitter} = Npm.require 'events'
clc = Npm.require 'cli-color'

defaultLogLevel = Meteor.settings?.public?.logLevel ? 'info'
specificLogLevels =  Meteor.settings?.public?.specificLogLevels ? {}
