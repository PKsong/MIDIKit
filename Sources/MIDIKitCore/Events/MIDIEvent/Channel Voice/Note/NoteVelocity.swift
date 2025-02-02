//
//  NoteVelocity.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

extension MIDIEvent {
    /// MIDI Note Velocity.
    /// (MIDI 1.0 / MIDI 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Note velocity is a 7-bit value when encoded for MIDI 1.0. A velocity of zero typically
    /// > functions as a Note Off, although this behavior is able to be bypassed.
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > The allowable Velocity range for a MIDI 2.0 Note On message is 0x0000-0xFFFF. Unlike the
    /// > MIDI 1.0 Note On message, a velocity value of zero does not function as a Note Off.
    /// > When translating a MIDI 2.0 Note On message to the MIDI 1.0 Protocol, if the translated
    /// > MIDI 1.0 value of the Velocity is zero, then the Translator shall replace the zero with a
    /// > value of 1.
    public typealias NoteVelocity = MIDIEvent.ChanVoice7Bit16BitValue
    
    /// MIDI Note Velocity.
    /// (MIDI 1.0 / MIDI 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Note velocity is a 7-bit value when encoded for MIDI 1.0. A velocity of zero typically
    /// > functions as a Note Off, although this behavior is able to be bypassed.
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > The allowable Velocity range for a MIDI 2.0 Note On message is 0x0000-0xFFFF. Unlike the
    /// > MIDI 1.0 Note On message, a velocity value of zero does not function as a Note Off.
    /// > When translating a MIDI 2.0 Note On message to the MIDI 1.0 Protocol, if the translated
    /// > MIDI 1.0 value of the Velocity is zero, then the Translator shall replace the zero with a
    /// > value of 1.
    public typealias NoteVelocityValidated = NoteVelocity.Validated
}
