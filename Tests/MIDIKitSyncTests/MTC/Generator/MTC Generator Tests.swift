//
//  MTC Generator Tests.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

@testable import MIDIKitSync
import TimecodeKit
import XCTest

final class MTC_Generator_Generator_Tests: XCTestCase {
    func testMTC_Generator_Default() {
        // just testing variations on syntax
        
        let mtcGen1 = MTCGenerator()
        mtcGen1.midiOutHandler = { [weak self] (midiMessage) in
            _ = self
            _ = midiMessage
        }
        
        _ = MTCGenerator { [weak self] (midiMessage) in
            _ = self
            _ = midiMessage
        }
        
        _ = MTCGenerator(midiOutHandler: { (midiMessage) in
            _ = midiMessage
        })
        
        _ = MTCGenerator { (midiMessage) in
            _ = midiMessage
        }
    }
}

#endif
