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
output.sendMessage(help.noteOn(60, 127)); // note=50, vel=127, channel=0
output.sendMessage(help.noteOff(53, 80, 3)); // note=53, vel=80, channel=3
output.sendMessage(help.pitchBend(8192)); // pitchbend centered, channel=0
output.sendMessage(help.cc(123, 0)); // all notes off/ continuous control 123
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
Supported messages:

- noteOn
- noteOff
- pitchBend
- cc
- clock
- start
- songPosition
- channelPressure

Use these messages for input and output. See examples above for more detail.
```javascript
// input
parser.on('clock', function(){
  console.log('24 of these per quarter note :P');
});

// output
var pressure = 127;
var channel = 0
output.sendMessage(help.channelPressure(pressure, channel));
```

## Notes
System Exclusive messages are not handled correctly. By default, the npm midi module suppresses SysEx messages so this will not come up unless you explicitly enable sysex. 

There input checking -- if you use crazy values like `help.noteOn(240)` you will get invalid or incorrect midi messages.

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History

- 0.1.1 Add this handy README
- 0.1.0 initial

## License
Copyright (c) 2013 Charles Holbrow  
Licensed under the MIT license.
