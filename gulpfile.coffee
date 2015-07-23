gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'

inSrc = (path) -> 'src/' + path

paths =
  browser: [
    'browserPrefix.coffee',
    'microevent.coffee',
    'browserOutput.coffee',
    'logger.coffee',
    'browserSuffix.coffee',
  ].map inSrc
  node: [
    'nodePrefix.coffee',
    'consoleOutput.coffee',
    'logger.coffee',
    'nodeSuffix.coffee',
  ].map inSrc
  'meteor-server': [
    'meteorServerPrefix.coffee',
    'consoleOutput.coffee',
    'logger.coffee',
  ].map inSrc
  'meteor-browser': [
    'meteorBrowserPrefix.coffee',
    'microevent.coffee',
    'browserOutput.coffee',
    'logger.coffee',
  ].map inSrc

build = (name, compile=true) ->
  stream = gulp.src paths[name]
    .pipe concat("pince-#{name}.coffee")
  stream = stream.pipe coffee() if compile
  return stream.pipe gulp.dest 'dist/'

gulp.task 'build-node', ->
  build 'node'

gulp.task 'build-browser', ->
  build 'browser'

gulp.task 'build-meteor-server', ->
  # Due to annoying meteor/coffee namespacing, need to leave it as coffeescript.
  build 'meteor-server', false

gulp.task 'build-meteor-browser', ->
  # Due to annoying meteor/coffee namespacing, need to leave it as coffeescript.
  build 'meteor-browser', false

gulp.task 'build', ['build-node', 'build-browser', 'build-meteor-server', 'build-meteor-browser']

gulp.task 'default', ['build']
