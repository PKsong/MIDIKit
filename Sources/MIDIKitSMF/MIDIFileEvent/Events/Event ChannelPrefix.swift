//
//  Event ChannelPrefix.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
import MIDIKitCore

// MARK: - ChannelPrefix

// ------------------------------------
// NOTE: When revising these documentation blocks, they are duplicated in:
//   - MIDIFileEvent enum case (`case keySignature(delta:event:)`, etc.)
//   - MIDIFileEvent static constructors (`static func keySignature(...)`, etc.)
//   - MIDIFileEvent concrete payload structs (`KeySignature`, etc.)
//   - DocC documentation for each MIDIFileEvent type
// ------------------------------------

extension MIDIFileEvent {
    /// MIDI Channel Prefix event.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > The MIDI channel (`0 ... 15`) contained in this event may be used to associate a MIDI
    /// > channel with all events which follow, including System Exclusive and meta-events. This
    /// > channel is "effective" until the next normal MIDI event (which contains a channel) or the
    /// > next MIDI Channel Prefix meta-event. If MIDI channels refer to "tracks", this message may
    /// > help jam several tracks into a format 0 file, keeping their non-MIDI data associated with
    /// > a track. This capability is also present in Yamaha's ESEQ file format.
    public struct ChannelPrefix {
        /// Channel (`1 ... 16`) is stored zero-based (`0 ... 15`).
        public var channel: UInt4 = 0
        
        // MARK: - Init
        
        public init(channel: UInt4) {
            self.channel = channel
        }
    }
}

extension MIDIFileEvent.ChannelPrefix: Equatable { }

extension MIDIFileEvent.ChannelPrefix: Hashable { }

extension MIDIFileEvent.ChannelPrefix: Sendable { }

// MARK: - Static Constructors

extension MIDIFileEvent {
    /// MIDI Channel Prefix event.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > The MIDI channel (`0 ... 15`) contained in this event may be used to associate a MIDI
    /// > channel with all events which follow, including System Exclusive and meta-events. This
    /// > channel is "effective" until the next normal MIDI event (which contains a channel) or the
    /// > next MIDI Channel Prefix meta-event. If MIDI channels refer to "tracks", this message may
    /// > help jam several tracks into a format 0 file, keeping their non-MIDI data associated with
    /// > a track. This capability is also present in Yamaha's ESEQ file format.
    public static func channelPrefix(
        delta: DeltaTime = .none,
        channel: UInt4
    ) -> Self {
        .channelPrefix(
            delta: delta,
            event: .init(channel: channel)
        )
    }
}

// MARK: - Encoding

extension MIDIFileEvent.ChannelPrefix: MIDIFileEventPayload {
    public static let smfEventType: MIDIFileEventType = .channelPrefix
    
    public init(midi1SMFRawBytes rawBytes: some DataProtocol) throws {
        guard rawBytes.count == Self.midi1SMFFixedRawBytesLength else {
            throw MIDIFile.DecodeError.malformed(
                "Invalid number of bytes. Expected \(Self.midi1SMFFixedRawBytesLength) but got \(rawBytes.count)"
            )
        }
        
        let readChannel: UInt8 = try rawBytes.withDataReader { dataReader in
            // 3-byte preamble
            guard try dataReader.read(bytes: 3).elementsEqual(
                MIDIFile.kEventHeaders[Self.smfEventType]!
            ) else {
                throw MIDIFile.DecodeError.malformed(
                    "Event does not start with expected bytes."
                )
            }
            
            return try dataReader.readByte()
        }
        
        guard (0x0 ... 0xF).contains(readChannel) else {
            throw MIDIFile.DecodeError.malformed(
                "Channel number is out of bounds: \(readChannel)"
            )
        }
        
        guard let channel = readChannel.toUInt4Exactly else {
            throw MIDIFile.DecodeError.malformed(
                "Value(s) out of bounds."
            )
        }
        
        self.channel = channel
    }
    
    public func midi1SMFRawBytes<D: MutableDataProtocol>() -> D {
        // FF 20 01 cc
        // cc is channel number (0...15)
        
        D(MIDIFile.kEventHeaders[.channelPrefix]! + [channel.uInt8Value])
    }
    
    static let midi1SMFFixedRawBytesLength = 4

    public static func initFrom(
        midi1SMFRawBytesStream stream: some DataProtocol
    ) throws -> StreamDecodeResult {
        let requiredData = stream.prefix(midi1SMFFixedRawBytesLength)

        guard requiredData.count == midi1SMFFixedRawBytesLength else {
            throw MIDIFile.DecodeError.malformed(
                "Unexpected byte length."
            )
        }

        let newInstance = try Self(midi1SMFRawBytes: requiredData)

        return (
            newEvent: newInstance,
            bufferLength: midi1SMFFixedRawBytesLength
        )
    }
    
    public var smfDescription: String {
        let chanString = channel.uInt8Value.hexString(padTo: 1, prefix: true)

        return "chanPrefix: \(chanString)"
    }

    public var smfDebugDescription: String {
        let chanString = channel.uInt8Value.hexString(padTo: 1, prefix: true)

        return "ChannelPrefix(\(chanString))"
    }
}
