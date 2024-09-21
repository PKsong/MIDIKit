//
//  NoOp Tests.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

@testable import MIDIKitCore
import XCTest

final class MIDIEventNoOp_Tests: XCTestCase {
    // swiftformat:options --wrapcollections preserve
    
    typealias NoOp = MIDIEvent.NoOp
    
    func testNoOp() {
        for grp: UInt4 in 0x0 ... 0xF {
            let event: MIDIEvent = .noOp(group: grp)
    
            XCTAssertEqual(
                event.umpRawWords(protocol: .midi2_0),
                [[
                    UMPWord(
                        0x00 + grp.uInt8Value,
                        0x00,
                        0x00,
                        0x00
                    )
                ]]
            )
        }
    }
}

#endif
