//
//  MIDIEndpoint Collection.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

extension Collection where Element: MIDIEndpoint {
    // Note: sortedByName() is already implemented on MIDIEndpoint
    // and requires no special implementation here for endpoints.
    
    /// Returns the array sorted alphabetically by MIDI object name.
    public func sortedByDisplayName() -> [Element] {
        sorted(by: {
            $0.displayName
                .localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        })
    }
}

// MARK: - first

extension Collection where Element: MIDIEndpoint {
    /// Returns the first endpoint matching the given name.
    public func first(
        whereDisplayName displayName: String,
        ignoringEmpty: Bool = false
    ) -> Element? {
        ignoringEmpty
            ? first(where: { ($0.displayName == displayName) && !$0.displayName.isEmpty })
            : first(where: { $0.displayName == displayName })
    }
    
    /// Returns the endpoint with matching unique ID.
    /// If not found, the first element matching the given display name is returned.
    public func first(
        whereUniqueID uniqueID: MIDIIdentifier,
        fallbackDisplayName: String,
        ignoringEmpty: Bool = false
    ) -> Element? {
        first(whereUniqueID: uniqueID) ??
            first(
                whereDisplayName: fallbackDisplayName,
                ignoringEmpty: ignoringEmpty
            )
    }
}

// MARK: - contains

extension Collection where Element: MIDIEndpoint {
    /// Returns true if the collection contains an endpoint matching the given name.
    public func contains(
        whereDisplayName displayName: String,
        ignoringEmpty: Bool = false
    ) -> Bool {
        first(
            whereDisplayName: displayName,
            ignoringEmpty: ignoringEmpty
        ) != nil
    }
    
    /// Returns true if the collection contains an endpoint with matching unique ID.
    /// If not found, the first element matching the given display name is checked.
    public func contains(
        whereUniqueID uniqueID: MIDIIdentifier,
        fallbackDisplayName: String,
        ignoringEmpty: Bool = false
    ) -> Bool {
        first(
            whereUniqueID: uniqueID,
            fallbackDisplayName: fallbackDisplayName,
            ignoringEmpty: ignoringEmpty
        ) != nil
    }
}

// MARK: - filter

extension Collection where Element: MIDIEndpoint {
    /// Returns all endpoints matching the given name.
    public func filter(
        whereName name: String,
        ignoringEmpty: Bool = false
    ) -> [Element] {
        ignoringEmpty
            ? filter { (name == $0.name) && !$0.name.isEmpty }
            : filter { $0.name == name }
    }
    
    /// Returns all endpoints matching the given display name.
    public func filter(
        whereDisplayName displayName: String,
        ignoringEmpty: Bool = false
    ) -> [Element] {
        ignoringEmpty
            ? filter { ($0.displayName == displayName) && !$0.displayName.isEmpty }
            : filter { $0.displayName == displayName }
    }
}

// MARK: - conversion

extension Collection where Element: MIDIEndpoint {
    /// Returns endpoint identity criteria describing the endpoints.
    public func asIdentities() -> Set<MIDIEndpointIdentity> {
        // for some reason Set(map { ... }) was not working
        // so we have to use reduce
        
        reduce(into: Set<MIDIEndpointIdentity>()) {
            $0.insert(.uniqueID($1.uniqueID))
        }
    }
    
    /// Returns endpoint identity criteria describing the endpoints.
    @_disfavoredOverload
    public func asIdentities() -> [MIDIEndpointIdentity] {
        map { .uniqueID($0.uniqueID) }
    }
}

#endif
