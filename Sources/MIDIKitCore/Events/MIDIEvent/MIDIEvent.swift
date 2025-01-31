//
//  MIDIEvent.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

// NOTE: When editing the inline docs block for these, it should be copied to:
// - The concrete payload struct in the enum case's associated value, and its inits
// - MIDIEvent.ChanVoiceTypes case

/// An individual MIDI Event.
///
/// MIDI events are constructed as enum cases containing event payload data. Various static
/// constructors are available for each event type.
///
/// In both MIDI 1.0 and MIDI 2.0, events are divided into several main categories:
///
/// - Channel-Voice
/// - System-Common
/// - System-Exclusive
/// - System-Real-Time
/// - Utility (Applicable to MIDI 2.0 only)
///
/// MIDIKit provides type-safe abstractions for all possible events and values. For this reason, it
/// is not necessary (and is discouraged) to use raw bytes when constructing or parsing events.
public enum MIDIEvent {
    // -------------------
    // MARK: Channel Voice
    // -------------------
    
    /// Channel Voice Message: Note On
    /// (MIDI 1.0 / 2.0)
    case noteOn(NoteOn)
    
    /// Channel Voice Message: Note Off
    /// (MIDI 1.0 / 2.0)
    case noteOff(NoteOff)
    
    /// Channel Voice Message: Per-Note Control Change (CC)
    /// (MIDI 2.0)
    case noteCC(NoteCC)
    
    /// Channel Voice Message: Per-Note Pitch Bend
    /// (MIDI 2.0)
    case notePitchBend(NotePitchBend)
    
    /// Channel Voice Message: Per-Note Pressure (Polyphonic Aftertouch)
    /// (MIDI 1.0 / 2.0)
    ///
    /// Also known as:
    /// - Pro Tools: "Polyphonic Aftertouch"
    /// - Logic Pro: "Polyphonic Aftertouch"
    /// - Cubase: "Poly Pressure"
    case notePressure(NotePressure)
    
    /// Channel Voice Message: Per-Note Management
    /// (MIDI 2.0)
    ///
    /// The MIDI 2.0 Protocol introduces a Per-Note Management message to enable independent control
    /// from Per- Note Controllers to multiple Notes on the same Note Number.
    case noteManagement(NoteManagement)
    
    /// Channel Voice Message: Channel Control Change (CC)
    /// (MIDI 1.0 / 2.0)
    case cc(CC)
    
    /// Channel Voice Message: Channel Program Change
    /// (MIDI 1.0 / 2.0)
    case programChange(ProgramChange)
    
    /// Channel Voice Message: Channel Pitch Bend
    /// (MIDI 1.0 / 2.0)
    case pitchBend(PitchBend)
    
    /// Channel Voice Message: Channel Pressure (Aftertouch)
    /// (MIDI 1.0 / 2.0)
    ///
    /// Also known as:
    /// - Pro Tools: "Mono Aftertouch"
    /// - Logic Pro: "Aftertouch"
    /// - Cubase: "Aftertouch"
    case pressure(Pressure)
    
    // -----------------------------------------------
    // MARK: Channel Voice - Parameter Number Messages
    // -----------------------------------------------
    
    /// RPN (Registered Parameter Number) Message,
    /// also referred to as Registered Controller in MIDI 2.0.
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > In order to set or change the value of a Registered Parameter (RPN), the following occurs:
    /// >
    /// > 1. Two Control Change messages are sent using CC 101 (0x65) and 100 (0x64) to select the
    /// > desired Registered Parameter Number.
    /// >
    /// > 2. When setting the Registered Parameter to a specific value, CC messages are sent to the
    /// > Data Entry MSB controller (CC 6). If the selected Registered Parameter requires the LSB to
    /// > be set, another CC message is sent to the Data Entry LSB controller (CC 38).
    /// >
    /// > 3. To make a relative adjustment to the selected Registered Parameter's current value, use
    /// > the Data Increment or Data Decrement controllers (CCs 96 & 97).
    /// >
    /// > Currently undefined RPN parameter numbers are all RESERVED for future MMA Definition.
    /// >
    /// > For custom Parameter Number use, see NRPN (Non-Registered Parameter Numbers).
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > In the MIDI 2.0 Protocol, Registered Controllers (RPN) and Assignable Controllers (NRPN)
    /// > use a single, unified message, making them much easier to use.
    /// >
    /// > As a result, CC 6, 38, 98, 99, 100, and 101 are not to be used in standalone CC messages,
    /// > as the new MIDI 2.0 RPN/NRPN UMP messages replace them.
    /// >
    /// > Registered Controllers (RPNs) have specific functions defined by MMA/AMEI specifications.
    /// > Registered Controllers map and translate directly to MIDI 1.0 Registered Parameter Numbers
    /// > (RPN, see Appendix D.2.3) and use the same definitions as MMA/AMEI approved RPN messages.
    /// > Registered Controllers are organized in 128 Banks (corresponds to RPN MSB), with 128
    /// > controllers per Bank (corresponds to RPN LSB).
    ///
    /// - Note: See Recommended Practise
    /// [RP-018](https://www.midi.org/specifications/midi1-specifications/midi-1-addenda/response-to-data-increment-decrement-controllers)
    /// of the MIDI 1.0 Spec Addenda.
    case rpn(RPN)
    
    /// NRPN (Non-Registered Parameter Number) Message,
    /// also referred to as Assignable Controller in MIDI 2.0.
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > In order to set or change the value of an Assignable Parameter (NRPN), the following
    /// > occurs:
    /// >
    /// > 1. Two Control Change messages are sent using CC 99 (0x63) and 98 (0x62) to select the
    /// > desired Assignable Parameter Number.
    /// >
    /// > 2. When setting the Assignable Parameter to a specific value, CC messages are sent to the
    /// > Data Entry MSB controller (CC 6). If the selected Registered Parameter requires the LSB to
    /// > be set, another CC message is sent to the Data Entry LSB controller (CC 38).
    /// >
    /// > 3. To make a relative adjustment to the selected Assignable Parameter's current value, use
    /// > the Data Increment or Data Decrement controllers (CCs 96 & 97).
    /// >
    /// > For registered Parameter Number use, see RPN (Registered Parameter Numbers).
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > In the MIDI 2.0 Protocol, Registered Controllers (RPN) and Assignable Controllers (NRPN)
    /// > use a single, unified message, making them much easier to use.
    /// >
    /// > As a result, CC 6, 38, 98, 99, 100, and 101 are not to be used in standalone CC messages,
    /// > as the new MIDI 2.0 RPN/NRPN UMP messages replace them.
    /// >
    /// > Assignable Controllers (NRPNs) have no specific function and are available for any device
    /// > or application-specific function. Assignable Controllers map and translate directly to
    /// > MIDI 1.0 Non-Registered Parameter Numbers (NRPN). Assignable Controllers are also
    /// > organized in 128 Banks (corresponds to NRPN MSB), with 128 controllers per Bank
    /// > (corresponds to NRPN LSB).
    ///
    /// See Recommended Practise
    /// [RP-018](https://www.midi.org/specifications/midi1-specifications/midi-1-addenda/response-to-data-increment-decrement-controllers)
    /// of the MIDI 1.0 Spec Addenda.
    case nrpn(NRPN)
    
    // ----------------------
    // MARK: System Exclusive
    // ----------------------
    
    /// System Exclusive: Manufacturer-specific (7-bit)
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Receivers should ignore non-universal Exclusive messages with ID numbers that do not
    /// > correspond to their own ID.
    /// >
    /// > Any manufacturer of MIDI hardware or software may use the system exclusive codes of any
    /// > existing product without the permission of the original manufacturer. However, they may
    /// > not modify or extend it in any way that conflicts with the original specification
    /// > published by the designer. Once published, an Exclusive format is treated like any other
    /// > part of the instruments MIDI implementation — so long as the new instrument remains within
    /// > the definitions of the published specification.
    case sysEx7(SysEx7)
    
    /// Universal System Exclusive (7-bit)
    /// (MIDI 1.0 / 2.0)
    ///
    /// Some standard Universal System Exclusive messages have been defined by the MIDI Spec. See
    /// the official MIDI 1.0 and 2.0 specs for details.
    ///
    /// - `deviceID` of `0x7F` indicates "All Devices".
    case universalSysEx7(UniversalSysEx7)
    
    /// System Exclusive: Manufacturer-specific (8-bit)
    /// (MIDI 2.0 only)
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > System Exclusive 8 messages have many similarities to the MIDI 1.0 Protocol’s original
    /// > System Exclusive messages, but with the added advantage of allowing all 8 bits of each
    /// > data byte to be used. By contrast, MIDI 1.0 Protocol System Exclusive requires a 0 in the
    /// > high bit of every data byte, leaving only 7 bits to carry actual data. A System Exclusive
    /// > 8 Message is carried in one or more 128-bit UMPs.
    case sysEx8(SysEx8)
    
    /// Universal System Exclusive (8-bit)
    /// (MIDI 2.0 only)
    ///
    /// - `deviceID` of `0x7F` indicates "All Devices".
    case universalSysEx8(UniversalSysEx8)
    
    // -------------------
    // MARK: System Common
    // -------------------
    
    /// System Common: Timecode Quarter-Frame
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > For device synchronization, MIDI Time Code uses two basic types of messages, described as
    /// > Quarter Frame and Full. There is also a third, optional message for encoding SMPTE user
    /// > bits. The Quarter Frame message communicates the Frame, Seconds, Minutes and Hours Count
    /// > in an 8-message sequence. There is also an MTC FULL FRAME message which is a MIDI System
    /// > Exclusive Message.
    case timecodeQuarterFrame(TimecodeQuarterFrame)
    
    /// System Common: Song Position Pointer
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > A sequencer's Song Position (SP) is the number of MIDI beats (1 beat = 6 MIDI clocks) that
    /// > have elapsed from the start of the song and is used to begin playback of a sequence from a
    /// > position other than the beginning of the song.
    case songPositionPointer(SongPositionPointer)
    
    /// System Common: Song Select
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Specifies which song or sequence is to be played upon receipt of a Start message in
    /// > sequencers and drum machines capable of holding multiple songs or sequences. This message
    /// > should be ignored if the receiver is not set to respond to incoming Real-Time messages
    /// > (MIDI Sync).
    case songSelect(SongSelect)
    
    /// System Common: Tune Request
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Used with analog synthesizers to request that all oscillators be tuned.
    case tuneRequest(TuneRequest)
    
    // ----------------------
    // MARK: System Real-Time
    // ----------------------
    
    /// System Real-Time: Timing Clock
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Clock-based MIDI systems are synchronized with this message, which is sent at a rate of 24
    /// > per quarter note. If Timing Clocks (`0xF8`) are sent during idle time they should be sent
    /// > at the current tempo setting of the transmitter even while it is not playing. Receivers
    /// > which are synchronized to incoming Real-Time messages (MIDI Sync mode) can thus phase lock
    /// > their internal clocks while waiting for a Start (`0xFA`) or Continue (`0xFB`) command.
    case timingClock(TimingClock)
    
    /// System Real-Time: Start
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Start (`0xFA`) is sent when a PLAY button on the master (sequencer or drum machine) is
    /// > pressed. This message commands all receivers which are synchronized to incoming Real-Time
    /// > messages (MIDI Sync mode) to start at the beginning of the song or sequence.
    case start(Start)
    
    /// System Real-Time: Continue
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Continue (`0xFB`) is sent when a CONTINUE button is hit. A sequence will continue from its
    /// > current location upon receipt of the next Timing Clock (`0xF8`).
    case `continue`(Continue)
    
    /// System Real-Time: Stop
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Stop (`0xFC`) is sent when a STOP button is hit. Playback in a receiver should stop
    /// > immediately.
    case stop(Stop)
    
    /// System Real-Time: Active Sensing
    /// (MIDI 1.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > Use of Active Sensing is optional for either receivers or transmitters. This byte (`0xFE`)
    /// > is sent every 300 ms (maximum) whenever there is no other MIDI data being transmitted. If
    /// > a device never receives Active Sensing it should operate normally. However, once the
    /// > receiver recognizes Active Sensing (`0xFE`), it then will expect to get a message of some
    /// > kind every 300 milliseconds. If no messages are received within this time period the
    /// > receiver will assume the MIDI cable has been disconnected for some reason and should turn
    /// > off all voices and return to normal operation. It is recommended that transmitters
    /// > transmit Active Sensing within 270ms and receivers judge at over 330ms leaving a margin of
    /// > roughly 10%.
    ///
    /// - Note: Use of Active Sensing in modern MIDI devices is uncommon and the use of this
    ///   standard has been deprecated as of MIDI 2.0.
    case activeSensing(ActiveSensing)
    
    /// System Real-Time: System Reset
    /// (MIDI 1.0 / 2.0)
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > System Reset commands all devices in a system to return to their initialized, power-up
    /// > condition. This message should be used sparingly, and should typically be sent by manual
    /// > control only. It should not be sent automatically upon power-up and under no condition
    /// > should this message be echoed.
    case systemReset(SystemReset)
    
    // -------------------------------
    // MARK: MIDI 2.0 Utility Messages
    // -------------------------------
    
    /// NOOP - No Operation
    /// (MIDI 2.0 Utility Messages)
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > The UMP Format provides a set of Utility Messages. Utility Messages include but are not
    /// > limited to NOOP and timestamps, and might in the future include UMP transport-related
    /// > functions.
    case noOp(NoOp)
    
    /// JR Clock (Jitter-Reduction Clock)
    /// (MIDI 2.0 Utility Messages)
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > The JR Clock message defines the current time of the Sender.
    /// >
    /// > A 16-bit time value in clock ticks of 1/31250 of one second (32 μsec, clock frequency of 1
    /// > MHz / 32).
    /// >
    /// > The time value is expected to wrap around every 2.09712 seconds.
    /// >
    /// > To avoid ambiguity of the 2.09712 seconds wrap, and to provide sufficient JR Clock
    /// > messages for the Receiver, the Sender shall send a JR Clock message at least once every
    /// > 250 milliseconds.
    case jrClock(JRClock)
    
    /// JR Timestamp (Jitter-Reduction Timestamp)
    /// (MIDI 2.0 Utility Messages)
    ///
    /// > MIDI 2.0 Spec:
    /// >
    /// > The JR Timestamp message defines the time of the following message(s). It is a complete
    /// > message.
    /// >
    /// > A 16-bit time value in clock ticks of 1/31250 of one second (32 μsec, clock frequency of 1
    /// > MHz / 32).
    case jrTimestamp(JRTimestamp)
}

extension MIDIEvent: Equatable { }

extension MIDIEvent: Hashable { }

extension MIDIEvent: Sendable { }
