//
//  HUIVPot.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
import MIDIKitCore

/// Enum describing a HUI surface V-Pot.
public enum HUIVPot: Equatable, Hashable {
    /// Channel strip V-Pot.
    case channel(UInt4)
    
    /// Edit/Assign V-Pot A.
    case editAssignA
    
    /// Edit Assign V-Pot B.
    case editAssignB
    
    /// Edit/Assign V-Pot C.
    case editAssignC
    
    /// Edit/Assign V-Pot D.
    case editAssignD
    
    /// Edit/Assign Scroll rotary knob.
    /// This is a user-input knob only and has no LED ring display.
    case editAssignScroll
    
    /// Internal:
    /// Initialize from raw value for encoding/decoding HUI message.
    init?(rawValue: UInt8) {
        switch rawValue {
        case 0x0 ... 0x7:
            let uInt4 = UInt4(rawValue)
            self = .channel(uInt4)
        case 0x8:
            self = .editAssignA
        case 0x9:
            self = .editAssignB
        case 0xA:
            self = .editAssignC
        case 0xB:
            self = .editAssignD
        case 0xC:
            self = .editAssignScroll
        default:
            return nil
        }
    }
    
    /// Internal:
    /// Raw value for encoding/decoding HUI message.
    @inlinable
    var rawValue: UInt8 {
        switch self {
        case let .channel(uInt4):
            return uInt4.uInt8Value
        case .editAssignA:
            return 0x8
        case .editAssignB:
            return 0x9
        case .editAssignC:
            return 0xA
        case .editAssignD:
            return 0xB
        case .editAssignScroll:
            return 0xC
        }
    }
    
    /// Returns `true` if the V-Pot has an LED ring display.
    @inlinable
    public var hasDisplay: Bool {
        switch self {
        case .editAssignScroll:
            return false
        default:
            return true
        }
    }
}

extension HUIVPot: Sendable { }

/// Internal:
/// Specialized HUI V-Pot value.
enum HUIVPotValue: Equatable, Hashable {
    /// V-Pot display LED ring. (11 LED ring with a lower LED)
    /// Only applies to HUI messages sent from the host in order to update
    /// a client surface's V-Pot LEDs.
    case display(HUIVPotDisplay)
    
    /// V-Pot rotary knob delta change -/+.
    /// Only applies to HUI messages sent from a client surface in order to transmit
    /// rotary knob input from the user to the host.
    case delta(Int7)
    
    /// Internal:
    /// Raw value for encoding/decoding HUI message.
    @inlinable
    var rawValue: UInt7 {
        switch self {
        case let .display(display):
            return display.rawIndex
        case let .delta(delta):
            return delta.rawUInt7Byte
        }
    }
    
    /// Internal:
    /// Returns wrapped `Int7` value.
    @inlinable
    var wrappedValue: Int7 {
        switch self {
        case let .display(display):
            return Int7(display.rawIndex)
        case let .delta(delta):
            return delta
        }
    }
}

extension HUIVPotValue: Sendable { }
