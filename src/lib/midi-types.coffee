module.exports.byStatus = byStatus  = []
module.exports.types    = types     = {}

class MidiMsgType
  constructor: (@name, @size, @hasChannel, @status, @isFourteenBit = false)->
    byStatus[status] = @
    types[name] = @

  toArray: (one, two, three)->
    if @isFourteenBit
      # (value = 8192, channel = 0)
      one = one or 8192
      return [@status + (two or 0), one % 128, Math.floor(one / 128)]

    if @size is 2
      # (note, velocity, channel = 0)
      # (cc#,  value,    channel = 0)
      return [@status + (three or 0), one, two]

    if @size is 1
      if @hasChannel
        # (value, channel = 0)
        return [@status + (two or 0), one]
      else
        # (value)
        return [@status, one]

    if @size is 0
      return [@status]


# Arguments to MidiMsgType
# name
# size/number data bytes
# has channle nibble
# status byte
# fourteen bit value
new MidiMsgType 'noteOn',           2,  true,   0x90
new MidiMsgType 'noteOff',          2,  true,   0x80
new MidiMsgType 'pitchBend',        2,  true,   0xE0, true
new MidiMsgType 'cc',               2,  true,   0xB0
new MidiMsgType 'channelPressure',  1,  true,   0xD0
new MidiMsgType 'clock',            0,  false,  0xF8
new MidiMsgType 'start',            0,  false,  0xFA
new MidiMsgType 'stop',             0,  false,  0xFC
new MidiMsgType 'continue',         0,  false,  0xfB
new MidiMsgType 'songPosition',     2,  false,  0xF2, true

# programatially export a toArray for each type
for name, type of types
  module.exports[name] = type.toArray.bind type
