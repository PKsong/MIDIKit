//
//  MIDIPacketList Utilities.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

import CoreMIDI

extension MIDIPacketList {
    /// Assembles a single Core MIDI `MIDIPacket` from a MIDI message byte array and wraps it in a
    /// Core MIDI `MIDIPacketList`.
    @_disfavoredOverload
    public init(data: [UInt8]) {
        let packetList = UnsafeMutablePointer<MIDIPacketList>(data: data)
        self = packetList.pointee
        packetList.deallocate()
    }
    
    /// Assembles an array of `UInt8` packet arrays into Core MIDI `MIDIPacket`s and wraps them in a
    /// `MIDIPacketList`.
    @_disfavoredOverload
    public init(data: [[UInt8]]) throws {
        let packetList = try UnsafeMutablePointer<MIDIPacketList>(data: data)
        self = packetList.pointee
        packetList.deallocate()
    }
}

extension UnsafeMutablePointer where Pointee == MIDIPacketList {
    /// Assembles a single Core MIDI `MIDIPacket` from a MIDI message byte array and wraps it in a
    /// Core MIDI `MIDIPacketList`.
    ///
    /// - Note: You must deallocate the pointer when finished with it.
    @_disfavoredOverload
    public init(data: [UInt8]) {
        // Create a buffer that is big enough to hold the data to be sent and
        // all the necessary headers.
        let bufferSize = data.count + kSizeOfMIDIPacketCombinedHeaders
    
        // the discussion section of MIDIPacketListAdd states that "The maximum
        // size of a packet list is 65536 bytes." Checking for that limit here.
        //        if bufferSize > 65_536 {
        //            logger.default("MIDI: assemblePacketList(data:) Error: Data array is too large (\(bufferSize) bytes), requires a buffer larger than 65536")
        //            return nil
        //        }
    
        let timeTag: UInt64 = mach_absolute_time()
    
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = .allocate(capacity: 1)
    
        // prepare packet
        var currentPacket: UnsafeMutablePointer<MIDIPacket> = MIDIPacketListInit(
            packetListPointer
        )
    
        // returns NULL if there was not room in the packet list for the event (?)
        currentPacket = MIDIPacketListAdd(
            packetListPointer,
            bufferSize,
            currentPacket,
            timeTag,
            data.count,
            data
        )
    
        self = packetListPointer
    }
    
    /// Assembles an array of `UInt8` packet arrays into Core MIDI `MIDIPacket`s and wraps them in a
    /// `MIDIPacketList`.
    ///
    /// - Note: You must deallocate the pointer when finished with it.
    /// - Note: System Exclusive messages must each be packed in a dedicated MIDIPacketList with no
    /// other events, otherwise MIDIPacketList may fail.
    @_disfavoredOverload
    public init(data: [[UInt8]]) throws {
        // Create a buffer that is big enough to hold the data to be sent and
        // all the necessary headers.
        let bufferSize = data
            .reduce(0) { $0 + $1.count * kSizeOfMIDIPacketHeader }
            + kSizeOfMIDIPacketListHeader
    
        // MIDIPacketListAdd's discussion section states that "The maximum size of a packet list is
        // 65536 bytes."
        guard bufferSize <= 65536 else {
            throw MIDIKitInternalError.malformed(
                "Data is too large (\(bufferSize) bytes). Maximum size is 65536 bytes."
            )
        }
    
        // As per Apple docs, timeTag must not be 0 when a packet is sent with `MIDIReceived()`. It
        // must be a proper timeTag.
        let timeTag: UInt64 = mach_absolute_time()
    
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = .allocate(capacity: 1)
    
        // prepare packet
        var currentPacket: UnsafeMutablePointer<MIDIPacket>! =
            MIDIPacketListInit(packetListPointer)
    
        for dataBlock in 0 ..< data.count {
            // returns NULL if there was not room in the packet list for the event
            currentPacket = MIDIPacketListAdd(
                packetListPointer,
                bufferSize,
                currentPacket,
                timeTag,
                data[dataBlock].count,
                data[dataBlock]
            )
    
            guard currentPacket != nil else {
                throw MIDIKitInternalError.malformed(
                    "Error adding MIDI packet to packet list."
                )
            }
        }
    
        self = packetListPointer
    }
}

#endif
