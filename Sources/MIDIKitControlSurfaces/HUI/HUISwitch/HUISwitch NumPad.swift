//
//  HUISwitch NumPad.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension HUISwitch {
    /// Numeric entry pad.
    public enum NumPad {
        case num0
        case num1
        case num2
        case num3
        case num4
        case num5
        case num6
        case num7
        case num8
        case num9
        
        case period       // .
        case plus         // +
        case minus        // -
        case enter
        case clr          // clr
        case equals       // =
        case forwardSlash // /
        case asterisk     // *
    }
}

extension HUISwitch.NumPad: Equatable { }

extension HUISwitch.NumPad: Hashable { }

extension HUISwitch.NumPad: Sendable { }

extension HUISwitch.NumPad: HUISwitchProtocol {
    public var zoneAndPort: HUIZoneAndPort {
        switch self {
        // Zone 0x13
        // Num Pad
        case .num0:         (0x13, 0x0)
        case .num1:         (0x13, 0x1)
        case .num4:         (0x13, 0x2)
        case .num2:         (0x13, 0x3)
        case .num5:         (0x13, 0x4)
        case .period:       (0x13, 0x5)
        case .num3:         (0x13, 0x6)
        case .num6:         (0x13, 0x7)
        // Zone 0x14
        // Num Pad
        case .enter:        (0x14, 0x0)
        case .plus:         (0x14, 0x1)
        // Zone 0x15
        // Num Pad
        case .num7:         (0x15, 0x0)
        case .num8:         (0x15, 0x1)
        case .num9:         (0x15, 0x2)
        case .minus:        (0x15, 0x3)
        case .clr:          (0x15, 0x4)
        case .equals:       (0x15, 0x5)
        case .forwardSlash: (0x15, 0x6)
        case .asterisk:     (0x15, 0x7)
        }
    }
}

extension HUISwitch.NumPad: CustomStringConvertible {
    public var description: String {
        switch self {
        // Zone 0x13
        // Num Pad
        case .num0:         "num0"
        case .num1:         "num1"
        case .num4:         "num4"
        case .num2:         "num2"
        case .num5:         "num5"
        case .period:       "period"
        case .num3:         "num3"
        case .num6:         "num6"
        // Zone 0x14
        // Num Pad
        case .enter:        "enter"
        case .plus:         "plus"
        // Zone 0x15
        // Num Pad
        case .num7:         "num7"
        case .num8:         "num8"
        case .num9:         "num9"
        case .minus:        "minus"
        case .clr:          "clr"
        case .equals:       "equals"
        case .forwardSlash: "forwardSlash"
        case .asterisk:     "asterisk"
        }
    }
}
