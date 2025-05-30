//
//  HUISwitch TimeDisplayStatus.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension HUISwitch {
    /// Time Display LEDs.
    public enum TimeDisplayStatus {
        /// "TIME CODE"
        /// Time format LEDs that are to the left of the main time display above the control room
        /// section (no button, LED only).
        case timecode
        
        /// "FEET"
        /// Time format LEDs that are to the left of the main time display above the control room
        /// section (no button, LED only).
        case feet
        
        /// "BEATS"
        /// Time format LEDs that are to the left of the main time display above the control room
        /// section (no button, LED only).
        case beats
        
        /// "RUDE SOLO LIGHT"
        /// Above the control room section
        case rudeSolo
    }
}

extension HUISwitch.TimeDisplayStatus: Equatable { }

extension HUISwitch.TimeDisplayStatus: Hashable { }

extension HUISwitch.TimeDisplayStatus: Sendable { }

extension HUISwitch.TimeDisplayStatus: HUISwitchProtocol {
    public var zoneAndPort: HUIZoneAndPort {
        switch self {
        // Zone 0x16
        // Timecode LEDs (no buttons, LEDs only)
        case .timecode: (0x16, 0x0)
        case .feet:     (0x16, 0x1)
        case .beats:    (0x16, 0x2)
        case .rudeSolo: (0x16, 0x3)
        }
    }
}

extension HUISwitch.TimeDisplayStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        // Zone 0x16
        // Timecode LEDs (no buttons, LEDs only)
        case .timecode: "timecode"
        case .feet:     "feet"
        case .beats:    "beats"
        case .rudeSolo: "rudeSolo"
        }
    }
}
