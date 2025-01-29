//
//  ContentView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import MIDIKitIO
import SwiftUI

struct ContentView: View {
    @Environment(ObservableMIDIManager.self) private var midiManager
    @Environment(MIDIHelper.self) private var midiHelper
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(
                "This example creates a virtual MIDI output port named \"\(MIDIHelper.virtualOutputName)\"."
            )
            .multilineTextAlignment(.center)
            
            Button("Send Note On C3") {
                midiHelper.sendNoteOn()
            }
            
            Button("Send Note Off C3") {
                midiHelper.sendNoteOff()
            }
            
            Button("Send CC1") {
                midiHelper.sendCC1()
            }
        }
        #if os(iOS)
        .font(.system(size: 18))
        #endif
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
