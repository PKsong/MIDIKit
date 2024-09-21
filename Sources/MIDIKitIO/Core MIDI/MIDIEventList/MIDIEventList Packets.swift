//
//  MIDIEventList Packets.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

#if compiler(>=6.0)
internal import CoreMIDI
#else
@_implementationOnly import CoreMIDI
#endif

#if compiler(>=6.0)
internal import MIDIKitInternals
#else
@_implementationOnly import MIDIKitInternals
#endif

#if !os(tvOS) && !os(watchOS)

@available(macOS 11, iOS 14, macCatalyst 14, *)
extension UnsafePointer where Pointee == CoreMIDI.MIDIEventList {
    /// Internal:
    /// Returns array of MIDIKit `UniversalPacketData` instances.
    func packets(
        refCon: UnsafeMutableRawPointer?,
        refConKnown: Bool
    ) -> [UniversalMIDIPacketData] {
        if pointee.numPackets == 0 {
            return []
        }
        
        let source = unpackMIDIRefCon(refCon: refCon, known: refConKnown)
    
        // Core MIDI's unsafeSequence() is not available on tvOS or watchOS at all
        let sequencedPackets = unsafeSequence().map {
            (
                words: $0.sequence().map { $0 },
                timeStamp: $0.pointee.timeStamp
            )
        }
    
        var packets: [UniversalMIDIPacketData] = []
    
        // using unsafeSequence() does not guarantee that each packet
        // only contains one UMP, it may contain multiple UMPs.
        // our solution is to manually parse the words and split them
        // into individual UMPs.
    
        for sequencedPacket in sequencedPackets {
            for umpWords in parse(packetWords: sequencedPacket.words) {
                let ump = UniversalMIDIPacketData(
                    words: umpWords,
                    timeStamp: sequencedPacket.timeStamp,
                    source: source
                )
                packets.append(ump)
            }
        }
    
        return packets
    }
}

#endif

@available(macOS 11, iOS 14, macCatalyst 14, tvOS 15.0, watchOS 8.0, *)
extension UnsafePointer where Pointee == CoreMIDI.MIDIEventList {
    /// Internal:
    /// Parses an EventPacket's words and splits it into individual UMP messages.
    fileprivate func parse(packetWords: [UMPWord]) -> [[UMPWord]] {
        guard !packetWords.isEmpty else { return [] }
    
        var results: [[UMPWord]] = []
    
        var curWord = 0
    
        let wordsRemain = { packetWords.count - curWord }
    
        // iterate through words, chunking into UMPs based on
        // expected number of words for the UMP Message Type
        while curWord < packetWords.count {
            guard let mt = UInt4(exactly: packetWords[curWord] >> 28),
                  let mtype = MIDIUMPMessageType(rawValue: mt),
                  wordsRemain() >= mtype.wordLength
            else { curWord = packetWords.count; continue }
    
            let expectedWordCount = mtype.wordLength
    
            let umpWords = packetWords[curWord ..< curWord + expectedWordCount]
    
            results.append(Array(umpWords))
    
            curWord += expectedWordCount
        }
    
        return results
    }
}
