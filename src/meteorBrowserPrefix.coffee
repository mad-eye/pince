moment = (date) -> moment
moment.format = (format) -> ""

defaultLogLevel = Meteor.settings?.public?.logLevel ? 'info'
specificLogLevels =  Meteor.settings?.public?.specificLogLevels ? {}
