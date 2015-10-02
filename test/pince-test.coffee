sinon = require 'sinon'
{assert} = require 'chai'
Logger = require './pince-node'

describe 'Logger', ->
  beforeEach ->
    Logger._output = sinon.spy()

  describe 'basic', ->
    data = null

    beforeEach ->
      Logger.setLevel 'info'
      log = new Logger('test')
      log.info 'foo'
      data = Logger._output.getCall(0).args[0]

    it 'should log messages', ->
      assert.deepEqual data.messages, ['foo']

    it 'should assign correct level', ->
      assert.equal data.level, 'info'

    it 'should assign correct name', ->
      assert.equal data.name, 'test'

    it 'should assign a timestamp', ->
      assert.ok data.timestamp

  describe 'levels', ->
    log = null

    beforeEach ->
      Logger.setLevel 'info'
      log = new Logger('test')

    it 'should log messages of equal level', ->
      log.info 'foo'
      assert.isTrue Logger._output.called

    it 'should log messages of higher level', ->
      log.warn 'foo'
      assert.isTrue Logger._output.called

    it 'should not log messages of lower level', ->
      log.debug 'foo'
      assert.isFalse Logger._output.called

  describe 'individual levels', ->
    routerLog = controllerLog = null

    beforeEach ->
      Logger._output = sinon.spy()
      Logger.setLevel('info')
      Logger.setLevel('controller', 'trace')
      routerLog = new Logger('router')
      controllerLog = new Logger('controller')

    it 'should not apply to differently named routers', ->
      routerLog.trace "Can't hear me!"
      assert.isFalse Logger._output.called

    it 'should apply to correctly named routers', ->
      controllerLog.trace "Can hear me."
      data = Logger._output.getCall(0).args[0]
      assert.equal data.name, 'controller'
      assert.equal data.level, 'trace'

  describe 'multiple individual levels', ->
    routerLog = controllerLog = null

    beforeEach ->
      Logger._output = sinon.spy()
      Logger.setLevels router:'debug', controller:'warn'
      routerLog = new Logger('router')
      controllerLog = new Logger('controller')

    it 'should allow named routers', ->
      routerLog.info "Finally! Someone is listening to me."
      data = Logger._output.getCall(0).args[0]
      assert.equal data.name, 'router'
      assert.equal data.level, 'info'

    it 'should filter named routers', ->
      controllerLog.info "Hello? Hello??"
      assert.isFalse Logger._output.called

  describe 'hierarchical levels', ->
    routerLog = controllerLog = null

    beforeEach ->
      Logger._output = sinon.spy()
      routerLog = new Logger('myPackage:router')
      controllerLog = new Logger('myPackage:controller')
      Logger.setLevel 'warn'
      Logger.setLevel 'myPackage', 'info'
      Logger.setLevel 'myPackage:controller', 'debug'

    it 'should not apply to differently named loggers', ->
      otherLog = new Logger('other')
      otherLog.info 'Crickets.'
      assert.isFalse Logger._output.called

    it 'should apply top level to non-specific sub-loggers -- pass', ->
      routerLog.info 'You can see this.'
      assert.isTrue Logger._output.called

    it 'should apply top level to non-specific sub-loggers -- filter', ->
      routerLog.debug 'You cannot see this; myPackage level is set to info.'
      assert.isFalse Logger._output.called

    it 'should apply specific level to specific sub-loggers', ->
      controllerLog.debug 'You can see this, myPackage:controller level is set to debug.'
      assert.isTrue Logger._output.called

  describe 'formatter', ->
