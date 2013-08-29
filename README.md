# midi-help

Companion to [npm midi package](https://npmjs.org/package/midi)

## Getting Started
Install the module with: `$ npm install midi-help`

Sending MIDI
```javascript
var help = require('midi-help');
var midi = require('midi');
var output = new midi.output();

output.openPort(0);
// send noteOn where noteNumber=60, velocity=127, channel=0
output.sendMessage(help.noteOn(60, 127));
// send noteOn where noteNumber=53, velocity=80, channel=3
output.sendMessage(help.noteOff(53, 80, 3))
// send pitchbend=8192 (perfect center), on default channel of 0
output.sendMessage(help.pitchBend(8192));
// send all notes off (continuous controller 123)
output.sendMessage(help.cc(123, 0));
```

Listening for MIDI
```javascript
input = new midi.input();
parser = new help.MidiParser();

input.on('message', function(deltaTime, message) {
  parser.parseByte(message);
});

parser.on('noteOn', function(note, velocity, channel){
  console.log('noteOn:', note, velocity, channel);
});

parser.on('noteOff', function(note, velocity, channel){
  console.log('noteOff:', note, velocity, channel);
});
```
## Documentation
Supported messages. parser will emit messages for each of these event types. You can also create arrays to pass in to `output.sendMessage`

- noteOn
- noteOff
- pitchBend
- cc
- clock
- start
- songPosition
- channelPressure

## Notes
System Exclusive messages are not handled correctly. By default, the npm midi module suppresses SysEx messages so this will not come up unless you explicitly enable sysex. 

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History

- 0.1.0 initial

## License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
