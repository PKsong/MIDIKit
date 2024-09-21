//
//  TopView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import MIDIKitControlSurfaces
import SwiftUI

extension HUISurfaceView {
    struct TopView: View {
        @EnvironmentObject var huiSurface: HUISurface
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text((huiSurface.isRemotePresent ? "🟢" : "🔴") + " Host")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        Spacer()
                            .frame(height: 8)
                        Text("hui")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .frame(width: HUISurfaceView.kLeftSideViewWidth)
                            .foregroundColor(.white)
                    }
                    MeterBridgeView()
                    LargeTextDisplayView()
                        .frame(width: HUISurfaceView.kRightSideViewWidth)
                    Spacer()
                }
                .background(Color.black)
            }
        }
    }
}
