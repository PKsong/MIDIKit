//
//  CC.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

extension MIDIEvent {
    /// Channel Voice Message: Control Change (CC)
    /// (MIDI 1.0 / 2.0)
    public struct CC {
        /// Controller
        public var controller: Controller
    
        /// Value
        @ValueValidated
        public var value: Value
    
        /// Channel Number (`0x0 ... 0xF`)
        public var channel: UInt4
    
        /// UMP Group (`0x0 ... 0xF`)
        public var group: UInt4 = 0x0
    
        /// Channel Voice Message: Control Change (CC)
        /// (MIDI 1.0 / 2.0)
        ///
        /// - Parameters:
        ///   - controller: Controller type
        ///   - value: Value
        ///   - channel: Channel Number (`0x0 ... 0xF`)
        ///   - group: UMP Group (`0x0 ... 0xF`)
        public init(
            controller: Controller,
            value: Value,
            channel: UInt4,
            group: UInt4 = 0x0
        ) {
            self.controller = controller
            self.value = value
            self.channel = channel
            self.group = group
        }
    
        /// Channel Voice Message: Control Change (CC)
        /// (MIDI 1.0 / 2.0)
        ///
        /// - Parameters:
        ///   - controller: Controller type
        ///   - value: Value
        ///   - channel: Channel Number (`0x0 ... 0xF`)
        ///   - group: UMP Group (`0x0 ... 0xF`)
        public init(
            controller: UInt7,
            value: Value,
            channel: UInt4,
            group: UInt4 = 0x0
        ) {
            self.controller = .init(number: controller)
            self.value = value
            self.channel = channel
            self.group = group
        }
    }
}

extension MIDIEvent.CC: Equatable { }

extension MIDIEvent.CC: Hashable { }

extension MIDIEvent.CC: Sendable { }

extension MIDIEvent {
    /// Channel Voice Message: Control Change (CC)
    /// (MIDI 1.0 / 2.0)
    ///
    /// - Parameters:
    ///   - controller: Controller type
    ///   - value: Value
    ///   - channel: Channel Number (`0x0 ... 0xF`)
    ///   - group: UMP Group (`0x0 ... 0xF`)
    public static func cc(
        _ controller: CC.Controller,
        value: CC.Value,
        channel: UInt4,
        group: UInt4 = 0x0
    ) -> Self {
        .cc(
            .init(
                controller: controller,
                value: value,
                channel: channel,
                group: group
            )
        )
    }
    
    /// Channel Voice Message: Control Change (CC)
    /// (MIDI 1.0 / 2.0)
    ///
    /// - Parameters:
    ///   - controller: Controller number
    ///   - value: Value
    ///   - channel: Channel Number (`0x0 ... 0xF`)
    ///   - group: UMP Group (`0x0 ... 0xF`)
    public static func cc(
        _ controller: UInt7,
        value: CC.Value,
        channel: UInt4,
        group: UInt4 = 0x0
    ) -> Self {
        .cc(
            .init(
                controller: controller,
                value: value,
                channel: channel,
                group: group
            )
        )
    }
}

extension MIDIEvent.CC {
    /// Returns the raw MIDI 1.0 status byte for the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage
    /// of MIDIKit, but is provided publicly for introspection and debugging purposes.
    public func midi1RawStatusByte() -> UInt8 {
        0xB0 + channel.uInt8Value
    }
    
    /// Returns the raw MIDI 1.0 data bytes for the event (excluding status byte).
    public func midi1RawDataBytes() -> (data1: UInt8, data2: UInt8) {
        (data1: controller.number.uInt8Value, data2: value.midi1Value.uInt8Value)
    }
    
    /// Returns the complete raw MIDI 1.0 message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage
    ///   of MIDIKit, but is provided publicly for introspection and debugging purposes.
    public func midi1RawBytes() -> [UInt8] {
        let dataBytes = midi1RawDataBytes()
        return [midi1RawStatusByte(), dataBytes.data1, dataBytes.data2]
    }
    
    private func umpMessageType(
        protocol midiProtocol: MIDIProtocolVersion
    ) -> MIDIUMPMessageType {
        switch midiProtocol {
        case .midi1_0:
            .midi1ChannelVoice
    
        case .midi2_0:
            .midi2ChannelVoice
        }
    }
    
    /// Returns the raw MIDI 2.0 UMP (Universal MIDI Packet) message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage
    ///   of MIDIKit, but is provided publicly for introspection and debugging purposes.
    public func umpRawWords(
        protocol midiProtocol: MIDIProtocolVersion
    ) -> [UMPWord] {
        let mtAndGroup = (umpMessageType(protocol: midiProtocol).rawValue.uInt8Value << 4) + group
            .uInt8Value
    
        switch midiProtocol {
        case .midi1_0:
            let word = UMPWord(
                mtAndGroup,
                midi1RawStatusByte(),
                controller.number.uInt8Value,
                value.midi1Value.uInt8Value
            )
    
            return [word]
    
        case .midi2_0:
            let word1 = UMPWord(
                mtAndGroup,
                midi1RawStatusByte(),
                controller.number.uInt8Value,
                0x00
            ) // reserved
    
            let word2 = value.midi2Value
    
            return [word1, word2]
        }
    }
}
