const events = require('events');
const should = require('should');
const help = require('../lib/midi-help');

const MidiParser = help.MidiParser;

describe('MidiParser', function() {
  it('should be an EventEmitter', function() {
    var parser;
    parser = new MidiParser();
    return parser.should.be.an.instanceOf(events.EventEmitter);
  });
  return describe('parseByte, parseBytes, parseArray', function() {
    it('0x92 0x93 60 80 should be a noteOn message on channel 3', function(done) {
      var parser;
      this.timeout(200);
      parser = new MidiParser();
      parser.on('noteOn', function(note, vel, channel) {
        3..should.eql(channel);
        return done();
      });
      return parser.parseArray([0x92, 0x93, 60, 80]);
    });
    it('0x91, 0x64, 0x65 should emit a "noteOn" with arguments: ' + 'noteNumber = 100, velocity = 101, channel = 1', function(done) {
      var parser;
      this.timeout(200);
      parser = new MidiParser();
      parser.on('noteOn', function(note, vel, ch) {
        note.should.eql(100);
        vel.should.eql(101);
        ch.should.eql(1);
        return done();
      });
      parser.parseByte(0x91);
      parser.parseByte(0x64);
      return parser.parseByte(0x65);
    });
    it('0xF8 should emit "clock"', function(done) {
      var parser;
      this.timeout(200);
      parser = new MidiParser();
      parser.on('clock', function() {
        return done();
      });
      return parser.parseByte(0xF8);
    });
    return it('0xE3, 5, 64 should emit "pitchBend" 8197, 3 (+5 PB, ch 3)', function(done) {
      var parser;
      this.timeout(200);
      parser = new MidiParser();
      parser.on('pitchBend', function(value, channel) {
        8197..should.eql(value);
        3..should.eql(channel);
        return done();
      });
      return parser.parseBytes(0xE3, 5, 64);
    });
  });
});

describe('toArray', function() {
  return describe('pitchBend', function() {
    return it('should convert (8197, 3) to [0xE3, 5, 64]', function() {
      var ans;
      ans = help.types.pitchBend.toArray(8197, 3);
      return ans.should.eql([0xE3, 5, 64]);
    });
  });
});
