'use strict'

events = require('events')
should = require('should')
help = require('../lib/midi-help')
MidiStreamParser = help.MidiStreamParser

describe 'MidiStreamParser', ->
  it 'should be an EventEmitter', ->
    parser = new MidiStreamParser
    parser.should.be.an.instanceOf events.EventEmitter

  describe 'parseByte, parseBytes, parseArray', ->

    it '0x92 0x93 60 80 should be a noteOn message on channel 3', (done)->
      @timeout 200
      parser = new MidiStreamParser
      parser.on 'noteOn', (note, vel, channel)->
        (3).should.eql channel
        done()
      parser.parseArray [0x92, 0x93, 60, 80]

    it '0x91, 0x64, 0x65 should emit a "noteOn" with arguments: ' +
       'noteNumber = 100, velocity = 101, channel = 1', (done)->
      @timeout(200)
      parser = new MidiStreamParser
      parser.on 'noteOn', (note, vel, ch)->
        note.should.eql 100
        vel.should.eql 101
        ch.should.eql 1
        done()
      parser.parseByte 0x91
      parser.parseByte 0x64
      parser.parseByte 0x65

    it '0xF8 should emit "clock"', (done)->
      @timeout 200
      parser = new MidiStreamParser
      parser.on 'clock', -> done()
      parser.parseByte 0xF8

    it '0xE3, 5, 64 should emit "pitchBend" 8197, 3 (+5 PB, ch 3)', (done)->
      @timeout 200
      parser = new MidiStreamParser
      parser.on 'pitchBend', (value, channel)->
        (8197).should.eql value
        (3).should.eql channel
        done()
      parser.parseBytes 0xE3, 5, 64

describe 'toArray', ->
  describe 'pitchBend', ->
    it 'should convert (8197, 3) to [0xE3, 5, 64]', ->
      ans = help.types.pitchBend.toArray(8197, 3)
      ans.should.eql [0xE3, 5, 64]

###
======== A Handy Little Mocha Reference ========
https://github.com/visionmedia/should.js
https://github.com/visionmedia/mocha

Mocha hooks:
  before ()-> # before describe
  after ()-> # after describe
  beforeEach ()-> # before each it
  afterEach ()-> # after each it

Should assertions:
  should.exist('hello')
  should.fail('expected an error!')
  true.should.be.ok
  true.should.be.true
  false.should.be.false

  (()-> arguments)(1,2,3).should.be.arguments
  [1,2,3].should.eql([1,2,3])
  should.strictEqual(undefined, value)
  user.age.should.be.within(5, 50)
  username.should.match(/^\w+$/)

  user.should.be.a('object')
  [].should.be.an.instanceOf(Array)

  user.should.have.property('age', 15)

  user.age.should.be.above(5)
  user.age.should.be.below(100)
  user.pets.should.have.length(5)

  res.should.have.status(200) #res.statusCode should be 200
  res.should.be.json
  res.should.be.html
  res.should.have.header('Content-Length', '123')

  [].should.be.empty
  [1,2,3].should.include(3)
  'foo bar baz'.should.include('foo')
  { name: 'TJ', pet: tobi }.user.should.include({ pet: tobi, name: 'TJ' })
  { foo: 'bar', baz: 'raz' }.should.have.keys('foo', 'bar')

  (()-> throw new Error('failed to baz')).should.throwError(/^fail.+/)

  user.should.have.property('pets').with.lengthOf(4)
  user.should.be.a('object').and.have.property('name', 'tj')
###
