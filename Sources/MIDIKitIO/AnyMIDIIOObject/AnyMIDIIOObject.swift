//
//  AnyMIDIIOObject.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

import Foundation
import SwiftUI

#if compiler(>=5.10)
/* private */ import CoreMIDI
#else
@_implementationOnly import CoreMIDI
#endif

/// Box to contain an instance of a strongly-typed system MIDI object.
///
/// Allows for simple switch case unwrapping when object type needs to be erased, such as
/// ``MIDIManager``'s handler for Core MIDI system notifications.
public enum AnyMIDIIOObject {
    case device(MIDIDevice)
    case entity(MIDIEntity)
    case inputEndpoint(MIDIInputEndpoint)
    case outputEndpoint(MIDIOutputEndpoint)
}

extension AnyMIDIIOObject: Equatable {
    // default implementation provided in MIDIIOObject
}

extension AnyMIDIIOObject: Hashable {
    // default implementation provided in MIDIIOObject
}

extension AnyMIDIIOObject: Identifiable {
    public typealias ID = CoreMIDIObjectRef
    public var id: ID { coreMIDIObjectRef }
}

extension AnyMIDIIOObject: Sendable { }

extension AnyMIDIIOObject: MIDIIOObject {
    public var objectType: MIDIIOObjectType {
        switch self {
        case let .device(device):
            return device.objectType
        case let .entity(entity):
            return entity.objectType
        case let .inputEndpoint(endpoint):
            return endpoint.objectType
        case let .outputEndpoint(endpoint):
            return endpoint.objectType
        }
    }
    
    public var name: String {
        switch self {
        case let .device(device):
            return device.name
        case let .entity(entity):
            return entity.name
        case let .inputEndpoint(endpoint):
            return endpoint.name
        case let .outputEndpoint(endpoint):
            return endpoint.name
        }
    }
    
    public var uniqueID: MIDIIdentifier {
        switch self {
        case let .device(device):
            return device.uniqueID
        case let .entity(entity):
            return entity.uniqueID
        case let .inputEndpoint(endpoint):
            return endpoint.uniqueID
        case let .outputEndpoint(endpoint):
            return endpoint.uniqueID
        }
    }
    
    public var coreMIDIObjectRef: CoreMIDIObjectRef {
        switch self {
        case let .device(device):
            return device.coreMIDIObjectRef
        case let .entity(entity):
            return entity.coreMIDIObjectRef
        case let .inputEndpoint(endpoint):
            return endpoint.coreMIDIObjectRef
        case let .outputEndpoint(endpoint):
            return endpoint.coreMIDIObjectRef
        }
    }
    
    public func asAnyMIDIIOObject() -> AnyMIDIIOObject {
        // ridiculous but we have to fulfill the conformance requirement
        self
    }
}

extension AnyMIDIIOObject {
    /// Initializes a case from an instance conforming to ``MIDIIOObject``.
    /// Returns nil if the concrete type of the instance is not recognized.
    init?(_ base: some MIDIIOObject) {
        switch base {
        case let obj as MIDIDevice:
            self = .device(obj)
        case let obj as MIDIEntity:
            self = .entity(obj)
        case let obj as MIDIInputEndpoint:
            self = .inputEndpoint(obj)
        case let obj as MIDIOutputEndpoint:
            self = .outputEndpoint(obj)
        default:
            return nil
        }
    }
    
    /// Returns a MIDIKit object wrapped in a strongly-typed enum case, optionally returning the
    /// cached object from the ``MIDIManager``.
    init?(
        coreMIDIObjectRef: MIDIObjectRef,
        coreMIDIObjectType: MIDIObjectType,
        using cache: MIDIIOObjectCache? = nil
    ) {
        guard coreMIDIObjectRef != 0 else { return nil }
    
        switch coreMIDIObjectType {
        case .other:
            return nil
    
        case .device, .externalDevice:
            if let cache,
               let getCachedDevice = cache.devices
                   .first(where: { $0.coreMIDIObjectRef == coreMIDIObjectRef })
            {
                self = .device(getCachedDevice)
            } else {
                self = .device(MIDIDevice(from: coreMIDIObjectRef))
            }
    
        case .entity, .externalEntity:
            self = .entity(MIDIEntity(from: coreMIDIObjectRef))
    
        case .source, .externalSource:
            if let cache,
               let getCachedEndpoint = cache.outputEndpoints
                   .first(where: { $0.coreMIDIObjectRef == coreMIDIObjectRef })
            {
                self = .outputEndpoint(getCachedEndpoint)
            } else {
                self = .outputEndpoint(MIDIOutputEndpoint(from: coreMIDIObjectRef))
            }
    
        case .destination, .externalDestination:
            if let cache,
               let getCachedEndpoint = cache.inputEndpoints
                   .first(where: { $0.coreMIDIObjectRef == coreMIDIObjectRef })
            {
                self = .inputEndpoint(getCachedEndpoint)
            } else {
                self = .inputEndpoint(MIDIInputEndpoint(from: coreMIDIObjectRef))
            }
    
        @unknown default:
            return nil
        }
    }
}

// MARK: - CustomStringConvertible

extension AnyMIDIIOObject: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .device(device):
            return "\(device)"
    
        case let .entity(entity):
            return "\(entity)"
    
        case let .inputEndpoint(endpoint):
            return "\(endpoint)"
    
        case let .outputEndpoint(endpoint):
            return "\(endpoint)"
        }
    }
}

// MARK: - Collection Methods

extension Collection where Element: MIDIIOObject {
    /// Return as `[` ``AnyMIDIIOObject`` `]`, type-erased representations of MIDIKit objects
    /// conforming to ``MIDIIOObject``.
    public func asAnyMIDIIOObjects() -> [AnyMIDIIOObject] {
        map { $0.asAnyMIDIIOObject() }
    }
}

#endif
