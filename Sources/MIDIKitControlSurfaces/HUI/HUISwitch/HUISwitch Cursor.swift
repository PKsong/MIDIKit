//
//  HUISwitch Cursor.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension HUISwitch {
    /// Cursor Movement / Mode / Scrub / Shuttle.
    public enum Cursor {
        case up
        case left
        case right
        case down
        case mode    // has LED; button in center of cursor direction keys
        
        case scrub   // has LED; to the right of the jogwheel
        case shuttle // has LED; to the right of the jogwheel
    }
}

extension HUISwitch.Cursor: Equatable { }

extension HUISwitch.Cursor: Hashable { }

extension HUISwitch.Cursor: Sendable { }

extension HUISwitch.Cursor: HUISwitchProtocol {
    public var zoneAndPort: HUIZoneAndPort {
        switch self {
        // Zone 0x0D
        // Cursor Movement / Mode / Scrub / Shuttle
        case .down:    return (0x0D, 0x0)
        case .left:    return (0x0D, 0x1)
        case .mode:    return (0x0D, 0x2)
        case .right:   return (0x0D, 0x3)
        case .up:      return (0x0D, 0x4)
        case .scrub:   return (0x0D, 0x5)
        case .shuttle: return (0x0D, 0x6)
        }
    }
}

extension HUISwitch.Cursor: CustomStringConvertible {
    public var description: String {
        switch self {
        // Zone 0x0D
        // Cursor Movement / Mode / Scrub / Shuttle
        case .down:    return "down"
        case .left:    return "left"
        case .mode:    return "mode"
        case .right:   return "right"
        case .up:      return "up"
        case .scrub:   return "scrub"
        case .shuttle: return "shuttle"
        }
    }
}
