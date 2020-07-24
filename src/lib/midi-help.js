const EventEmitter = require('events').EventEmitter;

const byStatus = module.exports.byStatus = [];
const types    = module.exports.types    = {};

class MidiMsgType {
  constructor(name, size, hasChannel, status, isFourteenBit=false) {
    this.name = name;
    this.size = size;
    this.hasChannel = hasChannel;
    this.status = status;
    this.isFourteenBit = isFourteenBit;
    byStatus[status] = this;
    types[name] = this;
  }

  toArray(one, two, three) {
    if (this.isFourteenBit) {
      // (value = 8192, channel = 0)
      one = one || 8192;
      return [this.status + (two || 0), one % 128, Math.floor(one / 128)];
    }

    if (this.size === 2) {
      // (note, velocity, channel = 0)
      // (cc#,  value,    channel = 0)
      return [this.status + (three || 0), one, two];
    }

    if (this.size === 1) {
      if (this.hasChannel) return [this.status + (two || 0), one]; // (value, channel=0)
      else return [this.status, one];
    }

    if (this.size === 0) {
      return [this.status];
    }
  }
}

new MidiMsgType('noteOn',           2,  true,   0x90);
new MidiMsgType('noteOff',          2,  true,   0x80);
new MidiMsgType('pitchBend',        2,  true,   0xE0, true);
new MidiMsgType('cc',               2,  true,   0xB0);
new MidiMsgType('channelPressure',  1,  true,   0xD0);
new MidiMsgType('clock',            0,  false,  0xF8);
new MidiMsgType('start',            0,  false,  0xFA);
new MidiMsgType('stop',             0,  false,  0xFC);
new MidiMsgType('continue',         0,  false,  0xfB);
new MidiMsgType('songPosition',     2,  false,  0xF2, true);

for (const [name, type] of Object.entries(types)) {
  module.exports[name] = type.toArray.bind(type);
};


/**
 * 
 */
class MidiParser extends EventEmitter {
  constructor() {
    super();
    this._midiMsgType = undefined;
    this._sysex = false;
    this._midi = {
      size: undefined,
      nibble1: undefined,
      nibble2: undefined,
      status: undefined,
      firstByte: undefined,
    };
  }

  parseByte (byte) {
    if (byte & 128) this._parseStatus(byte);
    else if (this._midi.firstByte === undefined) this._parseFirst(byte);
    else this._parseSecond(byte);
  }

  parseArray(input){
    input.forEach(byte => this.parseByte(byte))
  }

  parseBytes(...input) {
    input.forEach(byte => this.parseByte(byte));
  }

  _parseStatus(byte) {
    this._midi.status = byte;
    this._midi.nibble1 = byte & 0xF0;
    this._midi.nibble2 = byte & 0x0F;
    this._midiMsgType = byStatus[this._midi.nibble1];
    if (!this._midiMsgType) this._midiMsgType = byStatus[byte];
    this._midi.firstByte = undefined;
    if (!this._midiMsgType) {
      this.emit('mysteryStatusByte', byte);
      return;
    }
    if (this._midiMsgType.size === 0) this.emit(this._midiMsgType.name);
  }

  _parseFirst(byte) {
    if (!this._midiMsgType) {
      this.emit('mysteryDataByte', byte);
      return;
    }

    if (this._midiMsgType.size === 1) {
      if (this._midiMsgType.hasChannel) { 
        this.emit(this._midiMsgType.name, byte, this._midi.nibble2);
      }
      this._midi.status = undefined;
    } else {
      // expect another byte
      this._midi.firstByte = byte;
    }
  }

  _parseSecond(byte) {
    if (this._midiMsgType.isFourteenBit) {
      if (this._midiMsgType.hasChannel) {
        this.emit(
          this._midiMsgType.name,
          this._midi.firstByte + (byte * 128),
          this._midi.nibble2
        );
      }
    } else {
      this.emit(this._midiMsgType.name, this._midi.firstByte, byte, this._midi.nibble2);
    }
    this._midi.status = undefined;
    this._midi.firstByte = undefined;
  }
}

module.exports.MidiParser = MidiParser;
