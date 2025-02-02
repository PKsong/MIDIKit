//
//  Controller Undefined.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

extension MIDIEvent.CC.Controller {
    /// Undefined MIDI CC Controllers
    public enum Undefined {
        /// Undefined controller number 3
        /// (Int: 3, Hex: 0x03)
        case cc3
    
        /// Undefined controller number 9
        /// (Int: 9, Hex: 0x09)
        case cc9
    
        /// Undefined controller number 14
        /// (Int: 14, Hex: 0x0E)
        case cc14
    
        /// Undefined controller number 15
        /// (Int: 15, Hex: 0x0F)
        case cc15
    
        /// Undefined controller number 20
        /// (Int: 20, Hex: 0x14)
        case cc20
    
        /// Undefined controller number 21
        /// (Int: 21, Hex: 0x15)
        case cc21
    
        /// Undefined controller number 22
        /// (Int: 22, Hex: 0x16)
        case cc22
    
        /// Undefined controller number 23
        /// (Int: 23, Hex: 0x17)
        case cc23
    
        /// Undefined controller number 24
        /// (Int: 24, Hex: 0x18)
        case cc24
    
        /// Undefined controller number 25
        /// (Int: 25, Hex: 0x19)
        case cc25
    
        /// Undefined controller number 26
        /// (Int: 26, Hex: 0x1A)
        case cc26
    
        /// Undefined controller number 27
        /// (Int: 27, Hex: 0x1B)
        case cc27
    
        /// Undefined controller number 28
        /// (Int: 28, Hex: 0x1C)
        case cc28
    
        /// Undefined controller number 29
        /// (Int: 29, Hex: 0x1D)
        case cc29
    
        /// Undefined controller number 30
        /// (Int: 30, Hex: 0x1E)
        case cc30
    
        /// Undefined controller number 31
        /// (Int: 31, Hex: 0x1F)
        case cc31
    
        /// Undefined controller number 85
        /// (Int: 85, Hex: 0x55)
        case cc85
    
        /// Undefined controller number 86
        /// (Int: 86, Hex: 0x56)
        case cc86
    
        /// Undefined controller number 87
        /// (Int: 87, Hex: 0x57)
        case cc87
    
        /// Undefined controller number 89
        /// (Int: 89, Hex: 0x59)
        case cc89
    
        /// Undefined controller number 90
        /// (Int: 90, Hex: 0x5A)
        case cc90
    
        /// Undefined controller number 102
        /// (Int: 102, Hex: 0x66)
        case cc102
    
        /// Undefined controller number 103
        /// (Int: 103, Hex: 0x67)
        case cc103
    
        /// Undefined controller number 104
        /// (Int: 104, Hex: 0x68)
        case cc104
    
        /// Undefined controller number 105
        /// (Int: 105, Hex: 0x69)
        case cc105
    
        /// Undefined controller number 106
        /// (Int: 106, Hex: 0x6A)
        case cc106
    
        /// Undefined controller number 107
        /// (Int: 107, Hex: 0x6B)
        case cc107
    
        /// Undefined controller number 108
        /// (Int: 108, Hex: 0x6C)
        case cc108
    
        /// Undefined controller number 109
        /// (Int: 109, Hex: 0x6D)
        case cc109
    
        /// Undefined controller number 110
        /// (Int: 110, Hex: 0x6E)
        case cc110
    
        /// Undefined controller number 111
        /// (Int: 111, Hex: 0x6F)
        case cc111
    
        /// Undefined controller number 112
        /// (Int: 112, Hex: 0x70)
        case cc112
    
        /// Undefined controller number 113
        /// (Int: 113, Hex: 0x71)
        case cc113
    
        /// Undefined controller number 114
        /// (Int: 114, Hex: 0x72)
        case cc114
    
        /// Undefined controller number 115
        /// (Int: 115, Hex: 0x73)
        case cc115
    
        /// Undefined controller number 116
        /// (Int: 116, Hex: 0x74)
        case cc116
    
        /// Undefined controller number 117
        /// (Int: 117, Hex: 0x75)
        case cc117
    
        /// Undefined controller number 118
        /// (Int: 118, Hex: 0x76)
        case cc118
    
        /// Undefined controller number 119
        /// (Int: 119, Hex: 0x77)
        case cc119
    }
}

extension MIDIEvent.CC.Controller.Undefined: Equatable { }

extension MIDIEvent.CC.Controller.Undefined: Hashable { }

extension MIDIEvent.CC.Controller.Undefined: Identifiable {
    public var id: Self { self }
}

extension MIDIEvent.CC.Controller.Undefined: Sendable { }

extension MIDIEvent.CC.Controller.Undefined {
    /// Returns the controller number.
    @inlinable
    public var controller: UInt7 {
        // swiftformat:disable spaceInsideParens spaceInsideBrackets spacearoundoperators
        switch self {
        case .cc3:   3
        case .cc9:   9
        case .cc14:  14
        case .cc15:  15
        case .cc20:  20
        case .cc21:  21
        case .cc22:  22
        case .cc23:  23
        case .cc24:  24
        case .cc25:  25
        case .cc26:  26
        case .cc27:  27
        case .cc28:  28
        case .cc29:  29
        case .cc30:  30
        case .cc31:  31
        case .cc85:  85
        case .cc86:  86
        case .cc87:  87
        case .cc89:  89
        case .cc90:  90
        case .cc102: 102
        case .cc103: 103
        case .cc104: 104
        case .cc105: 105
        case .cc106: 106
        case .cc107: 107
        case .cc108: 108
        case .cc109: 109
        case .cc110: 110
        case .cc111: 111
        case .cc112: 112
        case .cc113: 113
        case .cc114: 114
        case .cc115: 115
        case .cc116: 116
        case .cc117: 117
        case .cc118: 118
        case .cc119: 119
        }
        // swiftformat:enable spaceInsideParens spaceInsideBrackets spacearoundoperators
    }
}

extension MIDIEvent.CC.Controller.Undefined {
    /// Returns the controller name as a human-readable String.
    public var name: String {
        "Undefined CC\(controller)"
    }
}
