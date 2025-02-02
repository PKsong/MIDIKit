//
//  MIDIEntity.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

// MARK: - Entity

/// A MIDI device, wrapping a Core MIDI `MIDIEntityRef`.
/// A device can contain zero or more entities, and an entity can contain zero or more inputs
/// and output endpoints.
///
/// Although this is a value-type struct, do not store or cache it as it will not remain updated.
public struct MIDIEntity: MIDIIOObject {
    // MARK: MIDIIOObject
    
    public let objectType: MIDIIOObjectType = .entity
    
    /// User-visible endpoint name.
    /// (`kMIDIPropertyName`)
    public internal(set) var name: String = ""
    
    /// System-global Unique ID.
    /// (`kMIDIPropertyUniqueID`)
    public internal(set) var uniqueID: MIDIIdentifier = .invalidMIDIIdentifier
    
    public let coreMIDIObjectRef: CoreMIDIEntityRef
    
    public func asAnyMIDIIOObject() -> AnyMIDIIOObject {
        .entity(self)
    }
    
    // MARK: Init
    
    init(from ref: CoreMIDIEntityRef) {
        assert(ref != CoreMIDIEntityRef())
    
        coreMIDIObjectRef = ref
        updateCachedProperties()
    }
    
    // MARK: - Cached Properties Update
    
    /// Update the cached properties
    mutating func updateCachedProperties() {
        if let name = try? MIDIKitIO.getName(of: coreMIDIObjectRef) {
            self.name = name
        }
    
        let uniqueID = MIDIKitIO.getUniqueID(of: coreMIDIObjectRef)
        if uniqueID != .invalidMIDIIdentifier {
            self.uniqueID = uniqueID
        }
    }
}

extension MIDIEntity: Equatable {
    // default implementation provided in MIDIIOObject
}

extension MIDIEntity: Hashable {
    // default implementation provided in MIDIIOObject
}

extension MIDIEntity: Identifiable {
    public typealias ID = CoreMIDIObjectRef
    public var id: ID { coreMIDIObjectRef }
}

extension MIDIEntity: Sendable { }

extension MIDIEntity: CustomDebugStringConvertible {
    public var debugDescription: String {
        "MIDIEntity(name: \(name.quoted), uniqueID: \(uniqueID), exists: \(exists))"
    }
}

extension MIDIEntity {
    /// Returns the device that owns the entity, if present.
    public var device: MIDIDevice? {
        try? getSystemDevice(for: coreMIDIObjectRef)
    }
    
    /// Returns the input endpoints for the entity.
    public var inputs: [MIDIInputEndpoint] {
        getSystemDestinations(for: coreMIDIObjectRef)
    }
    
    /// Returns the output endpoints for the entity.
    public var outputs: [MIDIOutputEndpoint] {
        getSystemSources(for: coreMIDIObjectRef)
    }
}

extension MIDIEntity {
    /// Returns `true` if the object exists in the system by querying Core MIDI.
    public var exists: Bool {
        device != nil
    }
}

#endif
