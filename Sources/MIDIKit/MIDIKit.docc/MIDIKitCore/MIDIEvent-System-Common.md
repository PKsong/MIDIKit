# System Common

System Common events include general system messages such as song select and MIDI Timecode (MTC) quarter-frame. These messages are not channel-specific.

## MIDI 1.0 & 2.0 Events

### Song Position Pointer

```swift
let event: MIDIEvent = .songPositionPointer(midiBeat: 160)
```

- See ``MIDIEvent/songPositionPointer(midiBeat:group:)`` for more details.
- Compatibility: MIDI 1.0 & 2.0

### Song Select

```swift
let event: MIDIEvent = .songSelect(number: 3)
```

- See ``MIDIEvent/songSelect(number:group:)`` for more details.
- Compatibility: MIDI 1.0 & 2.0

### Timecode Quarter-Frame

```swift
let event: MIDIEvent = .timecodeQuarterFrame(dataByte: 0b0110_0000)
```

- See ``MIDIEvent/timecodeQuarterFrame(dataByte:group:)`` for more details.
- Compatibility: MIDI 1.0 & 2.0

- Tip: MIDIKit contains separate dedicated abstractions for MTC synchronization. See **MIDIKitSync** documentation for details.

### Tune Request

```swift
let event: MIDIEvent = .tuneRequest()
```

- See ``MIDIEvent/tuneRequest(group:)`` for more details.
- Compatibility: MIDI 1.0 & 2.0

## Event Value Types

For an overview of how event value types work (such as note velocity, CC value, etc.) see <doc:MIDIKitCore-Value-Types>.

## Topics

### Constructors

- ``MIDIEvent/songPositionPointer(midiBeat:group:)``

- ``MIDIEvent/songSelect(number:group:)``

- ``MIDIEvent/timecodeQuarterFrame(dataByte:group:)``

- ``MIDIEvent/tuneRequest(group:)``

### Switch Case Unwrapping

- ``MIDIEvent/songPositionPointer(_:)``
- ``MIDIEvent/SongPositionPointer``

- ``MIDIEvent/songSelect(_:)``
- ``MIDIEvent/SongSelect``

- ``MIDIEvent/timecodeQuarterFrame(_:)``
- ``MIDIEvent/TimecodeQuarterFrame``

- ``MIDIEvent/tuneRequest(_:)``
- ``MIDIEvent/TuneRequest``
