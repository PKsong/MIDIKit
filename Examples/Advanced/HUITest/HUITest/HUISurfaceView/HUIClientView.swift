//
//  HUIClientView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import MIDIKitControlSurfaces
import MIDIKitIO
import SwiftUI

struct HUIClientView: View {
    @EnvironmentObject var midiManager: ObservableMIDIManager
    @StateObject private var huiSurface: HUISurface
    
    static let kHUIInputName = "MIDIKit HUI Input"
    static let kHUIOutputName = "MIDIKit HUI Output"
    
    init(midiManager: ObservableMIDIManager) {
        // set up HUI Surface object
        _huiSurface = {
            let huiSurface = HUISurface()
            
            huiSurface.modelNotificationHandler = { notification in
                // Logger.debug(notification)
            }
            
            huiSurface.midiOutHandler = { [weak midiManager] midiEvents in
                guard let output = midiManager?.managedOutputs[Self.kHUIOutputName]
                else {
                    Logger.debug("MIDI output missing.")
                    return
                }
            
                do {
                    try output.send(events: midiEvents)
                } catch {
                    Logger.debug(error.localizedDescription)
                }
            }
            
            return StateObject(wrappedValue: huiSurface)
        }()
    }
    
    var body: some View {
        HUISurfaceView()
            .frame(maxWidth: .infinity)
            .environmentObject(huiSurface)
        
            .onAppear {
                do {
                    try midiManager.addInput(
                        name: Self.kHUIInputName,
                        tag: Self.kHUIInputName,
                        uniqueID: .userDefaultsManaged(key: Self.kHUIInputName),
                        receiver: .events { [weak huiSurface] events, timeStamp, source in
                            // since handler callbacks from MIDI are on a CoreMIDI thread,
                            // parse the MIDI on the main thread because SwiftUI state in
                            // this app will be updated as a result
                            DispatchQueue.main.async {
                                huiSurface?.midiIn(events: events)
                            }
                        }
                    )
                    
                    try midiManager.addOutput(
                        name: Self.kHUIOutputName,
                        tag: Self.kHUIOutputName,
                        uniqueID: .userDefaultsManaged(key: Self.kHUIOutputName)
                    )
                } catch {
                    Logger.debug("Error setting up MIDI.")
                }
            }
    }
}

#if DEBUG
struct HUIClientView_Previews: PreviewProvider {
    static let midiManager = ObservableMIDIManager(clientName: "Preview", model: "", manufacturer: "")
    static var previews: some View {
        HUIClientView(midiManager: midiManager)
    }
}
#endif
