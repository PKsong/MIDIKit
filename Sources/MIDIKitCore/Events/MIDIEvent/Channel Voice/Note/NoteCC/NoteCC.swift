//
//  NoteCC.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

extension MIDIEvent {
    /// Channel Voice Message: Per-Note Control Change (CC)
    /// (MIDI 2.0)
    public struct NoteCC {
        /// Note Number
        ///
        /// If attribute is set to Pitch 7.9, then this value represents the note index.
        public var note: MIDINote
    
        /// Controller
        public var controller: PerNoteController
    
        /// Value
        @ValueValidated
        public var value: Value
    
        /// Channel Number (`0x0 ... 0xF`)
        public var channel: UInt4
    
        /// UMP Group (`0x0 ... 0xF`)
        public var group: UInt4 = 0x0
    
        /// Channel Voice Message: Per-Note Control Change (CC)
        /// (MIDI 2.0)
        ///
        /// - Parameters:
        ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
        ///   - controller: Per-Note Controller type
        ///   - value: Value
        ///   - channel: Channel Number (`0x0 ... 0xF`)
        ///   - group: UMP Group (`0x0 ... 0xF`)
        public init(
            note: UInt7,
            controller: PerNoteController,
            value: Value,
            channel: UInt4,
            group: UInt4 = 0x0
        ) {
            self.note = MIDINote(note)
            self.controller = controller
            self.value = value
            self.channel = channel
            self.group = group
        }
    
        /// Channel Voice Message: Per-Note Control Change (CC)
        /// (MIDI 2.0)
        ///
        /// - Parameters:
        ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
        ///   - controller: Per-Note Controller type
        ///   - value: Value
        ///   - channel: Channel Number (`0x0 ... 0xF`)
        ///   - group: UMP Group (`0x0 ... 0xF`)
        public init(
            note: MIDINote,
            controller: PerNoteController,
            value: Value,
            channel: UInt4,
            group: UInt4 = 0x0
        ) {
            self.note = note
            self.controller = controller
            self.value = value
            self.channel = channel
            self.group = group
        }
    }
}

extension MIDIEvent.NoteCC: Equatable { }

extension MIDIEvent.NoteCC: Hashable { }

extension MIDIEvent.NoteCC: Sendable { }

extension MIDIEvent {
    /// Channel Voice Message: Per-Note Control Change (CC)
    /// (MIDI 2.0)
    ///
    /// - Parameters:
    ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
    ///   - controller: Per-Note Controller type
    ///   - value: Value
    ///   - channel: Channel Number (`0x0 ... 0xF`)
    ///   - group: UMP Group (`0x0 ... 0xF`)
    public static func noteCC(
        note: UInt7,
        controller: NoteCC.PerNoteController,
        value: NoteCC.Value,
        channel: UInt4,
        group: UInt4 = 0x0
    ) -> Self {
        .noteCC(
            .init(
                note: note,
                controller: controller,
                value: value,
                channel: channel,
                group: group
            )
        )
    }
    
    /// Channel Voice Message: Per-Note Control Change (CC)
    /// (MIDI 2.0)
    ///
    /// - Parameters:
    ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
    ///   - controller: Per-Note Controller type
    ///   - value: Value
    ///   - channel: Channel Number (`0x0 ... 0xF`)
    ///   - group: UMP Group (`0x0 ... 0xF`)
    public static func noteCC(
        note: MIDINote,
        controller: NoteCC.PerNoteController,
        value: NoteCC.Value,
        channel: UInt4,
        group: UInt4 = 0x0
    ) -> Self {
        .noteCC(
            .init(
                note: note.number,
                controller: controller,
                value: value,
                channel: channel,
                group: group
            )
        )
    }
}

extension MIDIEvent.NoteCC {
    /// Returns the raw MIDI 2.0 UMP (Universal MIDI Packet) message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage
    /// of MIDIKit, but is provided publicly for introspection and debugging purposes.
    public func umpRawWords() -> [UMPWord] {
        let umpMessageType: MIDIUMPMessageType = .midi2ChannelVoice
    
        let mtAndGroup = (umpMessageType.rawValue.uInt8Value << 4) + group.uInt8Value
    
        // MIDI 2.0 only
    
        let statusByte: UInt8
        let index: UInt8
    
        switch controller {
        case let .assignable(ccNum):
            statusByte = 0x10
            index = ccNum
    
        case let .registered(ccNum):
            statusByte = 0x00
            index = ccNum.number
        }
    
        let word1 = UMPWord(
            mtAndGroup,
            statusByte + channel.uInt8Value,
            note.number.uInt8Value,
            index
        )
    
        let word2 = value.midi2Value
    
        return [word1, word2]
    }
}
