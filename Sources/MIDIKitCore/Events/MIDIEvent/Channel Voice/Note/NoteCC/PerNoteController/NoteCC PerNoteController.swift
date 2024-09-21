//
//  NoteCC PerNoteController.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

extension MIDIEvent.NoteCC {
    /// Per-Note Controller
    /// (MIDI 2.0)
    public enum PerNoteController: Equatable, Hashable {
        /// Registered Per-Note Controller
        case registered(Registered)
    
        /// Assignable Per-Note Controller (Non-Registered)
        case assignable(Assignable)
    }
}

extension MIDIEvent.NoteCC.PerNoteController: Sendable { }

extension MIDIEvent.NoteCC.PerNoteController: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .registered(cc):
            return "registered(\(cc.number))"
    
        case let .assignable(cc):
            return "assignable(\(cc))"
        }
    }
}

extension MIDIEvent.NoteCC.PerNoteController {
    /// Returns the controller number.
    public var number: UInt8 {
        switch self {
        case let .registered(cc):
            return cc.number
    
        case let .assignable(cc):
            return cc
        }
    }
}

extension MIDIEvent.NoteCC.PerNoteController {
    /// Initialize a Registered Per-Note Controller with raw controller number.
    public static func registered(_ controller: UInt8) -> Self {
        .registered(Registered(number: controller))
    }
}
