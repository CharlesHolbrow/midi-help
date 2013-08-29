events = require 'events'

midiTypes = require './midi-types'
byStatus = midiTypes.byStatus
module.exports = midiTypes

class MidiParser extends events.EventEmitter
  ################################
  # Public Interface
  constructor: ->
    @_midiMsgType = undefined
    @_sysex = false
    @_midi =
      size: undefined
      nibble1: undefined
      nibble2: undefined
      status: undefined
      firstByte: undefined
  parseByte: (byte)->
    if byte & 128 then @_parseStatus byte
    else if @_midi.firstByte is undefined then @_parseFirst byte
    else @_parseSecond byte
  parseArray: (input)->
    @parseByte(byte) for byte in input
  parseBytes: ->
    @parseByte(byte) for byte in arguments

  ################################
  # Private Interface
  _parseStatus: (byte)->
    @_midi.status = byte
    @_midi.nibble1 = byte & 0xF0
    @_midi.nibble2 = byte & 0x0F
    @_midiMsgType = byStatus[@_midi.nibble1]
    @_midiMsgType = byStatus[byte] unless @_midiMsgType
    @_midi.firstByte = undefined
    unless @_midiMsgType
      @emit 'mysteryStatusByte', byte
      return
    if @_midiMsgType.size == 0
      @emit @_midiMsgType.name

  _parseFirst: (byte)->
    unless @_midiMsgType
      @emit 'mysteryDataByte', byte
      return
    if @_midiMsgType.size == 1
      @emit @_midiMsgType.name, byte, @_midi.nibble2 if @_midiMsgType.hasChannel
      @_midi.status = undefined
    else
      # expect another byte
      @_midi.firstByte = byte

  _parseSecond: (byte)->
    if @_midiMsgType.isFourteenBit
      @emit @_midiMsgType.name,
        @_midi.firstByte + (byte * 128),
        @_midi.nibble2 if @_midiMsgType.hasChannel
    else
      @emit @_midiMsgType.name, @_midi.firstByte, byte, @_midi.nibble2
    @_midi.status = undefined
    @_midi.firstByte = undefined


module.exports.MidiParser = MidiParser
