//
//  MIDIPacket Utilities.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

import CoreMIDI
import Foundation

extension CoreMIDI.MIDIPacket {
    /// Returns the raw bytes of the `MIDIPacket`.
    @_disfavoredOverload @inlinable
    public var rawBytes: [UInt8] {
        withUnsafePointer(to: self) { $0.rawBytes }
    }
    
    /// Returns the time stamp of the `MIDIPacket`.
    @_disfavoredOverload @inlinable
    public var rawTimeStamp: MIDITimeStamp {
        withUnsafePointer(to: self) { $0.rawTimeStamp }
    }
}

extension UnsafePointer where Pointee == CoreMIDI.MIDIPacket {
    /// Returns the raw bytes of the `MIDIPacket` (`UnsafePointer`).
    @_disfavoredOverload @inlinable
    public var rawBytes: [UInt8] {
        CoreMIDI.MIDIPacket.extractBytes(from: self)
    }
    
    /// Returns the time stamp of the `MIDIPacket` (`UnsafePointer`).
    @_disfavoredOverload @inlinable
    public var rawTimeStamp: MIDITimeStamp {
        CoreMIDI.MIDIPacket.extractTimeStamp(from: self)
    }
}

extension UnsafeMutablePointer where Pointee == CoreMIDI.MIDIPacket {
    /// Returns the raw bytes of the `MIDIPacket` (`UnsafeMutablePointer`).
    @_disfavoredOverload @inlinable
    public var rawBytes: [UInt8] {
        UnsafePointer(self).rawBytes
    }
    
    /// Returns the time stamp of the `MIDIPacket` (`UnsafeMutablePointer`).
    @_disfavoredOverload @inlinable
    public var rawTimeStamp: MIDITimeStamp {
        UnsafePointer(self).rawTimeStamp
    }
}

// MARK: - Helpers

extension CoreMIDI.MIDIPacket {
    @inline(__always) @usableFromInline
    static let midiPacketLengthOffset: Int = MemoryLayout.offset(of: \CoreMIDI.MIDIPacket.length)!
    
    @inline(__always) @usableFromInline
    static let midiPacketDataOffset: Int = MemoryLayout.offset(of: \CoreMIDI.MIDIPacket.data)!
    
    @inline(__always) @usableFromInline
    static let midiPacketTimeStamp: Int = MemoryLayout.offset(of: \CoreMIDI.MIDIPacket.timeStamp)!
    
    @inlinable
    static func extractBytes(from ptr: UnsafeRawPointer) -> [UInt8] {
        // Access the raw memory instead of using the .pointee
        // This workaround is needed due to a variety of crashes that can occur when either the
        // thread sanitizer is on, or large/malformed MIDI packet lists / packets arrive
        
        let lengthPtr = ptr.advanced(by: midiPacketLengthOffset)
        // do NOT use withMemoryRebound() - it crashes due to alignment issues
        // also FYI, loadUnaligned compiles for macOS 10.10+/iOS 8+ but is only available in Xcode 14+
        let length = lengthPtr.loadUnaligned(as: UInt16.self)
        
        let rawMIDIPacketDataPtr = UnsafeRawBufferPointer(
            start: ptr + midiPacketDataOffset,
            count: Int(length)
        )
        
        return [UInt8](rawMIDIPacketDataPtr)
    }
    
    @inlinable
    static func extractTimeStamp(from ptr: UnsafeRawPointer) -> CoreMIDI.MIDITimeStamp {
        // Access the raw memory instead of using the .pointee
        // This workaround is needed due to a variety of crashes that can occur when either the
        // thread sanitizer is on, or large/malformed MIDI packet lists / packets arrive
        
        let timestampPtr = ptr.advanced(by: midiPacketTimeStamp)
        
        // do NOT use withMemoryRebound() - it crashes due to alignment issues
        // also FYI, loadUnaligned compiles for macOS 10.10+/iOS 8+ but is only available in Xcode 14+
        let timeStamp = timestampPtr.loadUnaligned(as: UInt64.self)
        
        return timeStamp
    }
}

#endif
