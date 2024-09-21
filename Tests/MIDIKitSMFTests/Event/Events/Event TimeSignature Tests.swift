//
//  Event TimeSignature Tests.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

@testable import MIDIKitSMF
import XCTest

final class Event_TimeSignature_Tests: XCTestCase {
    // swiftformat:options --wrapcollections preserve
    // swiftformat:disable spaceInsideParens spaceInsideBrackets spacearoundoperators
    
    func testInit_midi1SMFRawBytes() throws {
        let bytes: [UInt8] = [
            0xFF, 0x58, 0x04, // header
            0x02, // numerator
            0x01, // denominator
            0x18, // midiClocksBetweenMetronomeClicks
            0x08  // numberOf32ndNotesInAQuarterNote
        ]
        
        let event = try MIDIFileEvent.TimeSignature(midi1SMFRawBytes: bytes)
        
        XCTAssertEqual(event.numerator, 2)
        XCTAssertEqual(event.denominator, 1)
        XCTAssertEqual(event.midiClocksBetweenMetronomeClicks, 0x18)
        XCTAssertEqual(event.numberOf32ndNotesInAQuarterNote, 0x08)
    }
    
    func testMIDI1SMFRawBytes() {
        let event = MIDIFileEvent.TimeSignature(
            numerator: 2,
            denominator: 1
        )
        
        let bytes: [UInt8] = event.midi1SMFRawBytes()
        
        XCTAssertEqual(bytes, [
            0xFF, 0x58, 0x04, // header
            0x02, // numerator
            0x01, // denominator
            0x18, // midiClocksBetweenMetronomeClicks
            0x08  // numberOf32ndNotesInAQuarterNote
        ])
    }
}

#endif
