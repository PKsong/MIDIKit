//
//  EventParsingApp.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import MIDIKitIO
import SwiftUI

@main
struct EventParsingApp: App {
    @ObservedObject var midiManager = ObservableMIDIManager(
        clientName: "TestAppMIDIManager",
        model: "TestApp",
        manufacturer: "MyCompany"
    )
    
    @ObservedObject var midiHelper = MIDIHelper()
    
    init() {
        midiHelper.setup(midiManager: midiManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(midiManager)
                .environmentObject(midiHelper)
        }
    }
}
