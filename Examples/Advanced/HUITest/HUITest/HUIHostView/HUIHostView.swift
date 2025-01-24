//
//  HUIHostView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Controls
import MIDIKitControlSurfaces
import MIDIKitIO
import SwiftUI

struct HUIHostView: View {
    @EnvironmentObject var midiManager: ObservableMIDIManager
    @State var huiHostHelper: HUIHostHelper
    
    /// Convenience accessor for first HUI bank.
    private var huiBank0: HUIHostBank? { huiHostHelper.huiHost.banks.first }
    
    init(midiManager: ObservableMIDIManager) {
        // set up HUI Host object
        _huiHostHelper = State(wrappedValue: HUIHostHelper(midiManager: midiManager))
    }
    
    @State private var vPotDisplayFormat: VPotDisplayFormat = .single
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(
                """
                This window acts as a HUI host (ie: a DAW) and connects to the HUI surface.")
                
                To test the HUI surface with an actual DAW instead (Pro Tools, Logic, Cubase, etc.), close this window. The HUI Surface window can be used as a standalone HUI device."
                """
            )
            
            surfaceStatus
            
            hostBody
            
            Toggle("Log Pings", isOn: $huiHostHelper.logPing)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var surfaceStatus: some View {
        HStack {
            Circle()
                .fill(huiHostHelper.isRemotePresent ? .green : .red)
                .frame(width: 15, height: 15)
            Text("Surface")
        }
    }
    
    var hostBody: some View {
        GroupBox(label: Text("Channel Strip 1")) {
            VStack {
                Button("Send Random Meter Level") {
                    huiBank0?.transmitLevelMeter(
                        channel: 0,
                        side: .left,
                        level: HUISurfaceModelState.StereoLevelMeter.levelRange.randomElement()!
                    )
                    huiBank0?.transmitLevelMeter(
                        channel: 0,
                        side: .right,
                        level: HUISurfaceModelState.StereoLevelMeter.levelRange.randomElement()!
                    )
                }
                GroupBox(label: Text("V-Pot")) {
                    Picker("Style", selection: $vPotDisplayFormat) {
                        Text("Off").tag(VPotDisplayFormat.allOff)
                        Text("Position").tag(VPotDisplayFormat.single)
                        Text("Left Anchor (Send Level)").tag(VPotDisplayFormat.leftTo)
                        Text("Center Anchor (Pan)").tag(VPotDisplayFormat.centerTo)
                        Text("Center Radius (Width)").tag(VPotDisplayFormat.centerRadius)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: vPotDisplayFormat) { _, _ in
                        transmitVPot()
                    }
                    HStack {
                        if vPotDisplayFormat != .allOff {
                            Ribbon(position: $huiHostHelper.model.bank0.channel0.pan)
                                .foregroundColor(.secondary)
                                .backgroundColor(Color(nsColor: .controlBackgroundColor))
                                .indicatorWidth(15)
                                .frame(height: 20)
                                .onChange(
                                    of: huiHostHelper.model.bank0.channel0.pan
                                ) { oldValue, newValue in
                                    transmitVPot(value: newValue)
                                }
                        }
                        Toggle("Low", isOn: $huiHostHelper.model.bank0.channel0.vPotLowerLED)
                            .onChange(
                                of: huiHostHelper.model.bank0.channel0.vPotLowerLED
                            ) { oldValue, newValue in
                                transmitVPot(lowerLED: newValue)
                            }
                    }
                }
                Toggle("Solo", isOn: $huiHostHelper.model.bank0.channel0.solo)
                    .onChange(of: huiHostHelper.model.bank0.channel0.solo) { oldValue, newValue in
                        huiBank0?.transmitSwitch(.channelStrip(0, .solo), state: newValue)
                    }
                Toggle("Mute", isOn: $huiHostHelper.model.bank0.channel0.mute)
                    .onChange(of: huiHostHelper.model.bank0.channel0.mute) { oldValue, newValue in
                        huiBank0?.transmitSwitch(.channelStrip(0, .mute), state: newValue)
                    }
                GroupBox(label: Text("4-Character LCD")) {
                    LiveFormattedTextField(
                        value: $huiHostHelper.model.bank0.channel0.name,
                        formatter: MaxLengthFormatter(maxCharLength: 4)
                    )
                    .frame(width: 100)
                    .onChange(of: huiHostHelper.model.bank0.channel0.name) { oldValue, newValue in
                        huiBank0?.transmitSmallDisplay(
                            .channel(0),
                            text: .init(lossy: newValue)
                        )
                    }
                }
                Toggle("Selected", isOn: $huiHostHelper.model.bank0.channel0.selected)
                    .onChange(of: huiHostHelper.model.bank0.channel0.selected) { oldValue, newValue in
                        huiBank0?.transmitSwitch(.channelStrip(0, .select), state: newValue)
                    }
                GroupBox(label: Text("Fader")) {
                    Ribbon(position: $huiHostHelper.model.bank0.channel0.faderLevel)
                        .foregroundColor(
                            huiHostHelper.model.bank0.channel0.faderTouched
                                ? .green
                                : .secondary
                        )
                        .backgroundColor(Color(nsColor: .controlBackgroundColor))
                        .indicatorWidth(15)
                        .frame(height: 20)
                        .onChange(
                            of: huiHostHelper.model.bank0.channel0.faderLevel
                        ) { oldValue, newValue in
                            let scaledLevel = UInt14(newValue * Float(UInt14.max))
                            huiBank0?.transmitFader(level: scaledLevel, channel: 0)
                        }
                        .disabled(huiHostHelper.model.bank0.channel0.faderTouched)
                }
            }
            .frame(width: 250, height: 300)
        }
    }
    
    func ledState(_ value: Float) -> HUIVPotDisplay.LEDState {
        switch vPotDisplayFormat {
        case .allOff:
            return .allOff
        case .single:
            return .single(unitInterval: Double(value))
        case .leftTo:
            return .left(toUnitInterval: Double(value))
        case .centerTo:
            return .center(toUnitInterval: Double(value))
        case .centerRadius:
            return .centerRadius(unitInterval: Double(value))
        }
    }
    
    func transmitVPot(value: Float? = nil, lowerLED: Bool? = nil) {
        huiBank0?.transmitVPot(
            .channel(0),
            display: .init(
                leds: ledState(value ?? huiHostHelper.model.bank0.channel0.pan),
                lowerLED: lowerLED ?? huiHostHelper.model.bank0.channel0.vPotLowerLED
            )
        )
    }
    
    private enum VPotDisplayFormat: Equatable, Hashable, CaseIterable {
        case allOff
        case single
        case leftTo
        case centerTo
        case centerRadius
    }
}
