//
//  Event SMPTEOffset.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
import MIDIKitCore
import TimecodeKitCore

// MARK: - SMPTEOffset

// ------------------------------------
// NOTE: When revising these documentation blocks, they are duplicated in:
//   - MIDIFileEvent enum case (`case keySignature(delta:event:)`, etc.)
//   - MIDIFileEvent static constructors (`static func keySignature(...)`, etc.)
//   - MIDIFileEvent concrete payload structs (`KeySignature`, etc.)
//   - DocC documentation for each MIDIFileEvent type
// ------------------------------------

extension MIDIFileEvent {
    /// Specify the SMPTE time at which the track is to start.
    /// This optional event, if present, should occur at the start of a track,
    /// at `time == 0`, and prior to any MIDI events.
    /// Defaults to `00:00:00:00 @ 24fps`.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > MIDI SMPTE Offset subframes (fractional frames) are always in 100ths of a frame, even in
    /// > SMPTE-based tracks which specify a different frame subdivision for delta-times.
    public struct SMPTEOffset: Equatable, Hashable {
        /// Timecode hour.
        /// Valid range: ` 0 ... 23`.
        public var hours: UInt8 = 0 {
            didSet {
                if oldValue != hours { hours_Validate() }
            }
        }
        
        private mutating func hours_Validate() {
            hours = hours.clamped(to: 0 ... 23)
        }
        
        /// Timecode minutes.
        /// Valid range: `0 ... 59`.
        public var minutes: UInt8 = 0 {
            didSet {
                if oldValue != minutes { minutes_Validate() }
            }
        }
        
        private mutating func minutes_Validate() {
            minutes = minutes.clamped(to: 0 ... 59)
        }
        
        /// Timecode seconds.
        /// Valid range: `0 ... 59`.
        public var seconds: UInt8 = 0 {
            didSet {
                if oldValue != seconds { seconds_Validate() }
            }
        }
        
        private mutating func seconds_Validate() {
            seconds = seconds.clamped(to: 0 ... 59)
        }
        
        /// Timecode frames.
        /// Valid range is dependent on the `frameRate` property
        /// (`0 ... 23` for 24fps, `0 ... 29` for 30fps, etc.).
        public var frames: UInt8 = 0 {
            didSet {
                if oldValue != frames { frames_Validate() }
            }
        }
        
        private mutating func frames_Validate() {
            switch frameRate {
            case .fps24: frames = frames.clamped(to: 0 ... 23)
            case .fps25: frames = frames.clamped(to: 0 ... 25)
            case .fps30, .fps29_97d: frames = frames.clamped(to: 0 ... 29)
            }
        }
        
        /// Timecode subframes.
        /// Valid range: `0 ... 99`.
        /// The number of fractional frames, in 100ths of a frame (even in SMPTE-based tracks using
        /// a different frame subdivision, defined in the `MThd` MIDI file header chunk).
        public var subframes: UInt8 = 0 {
            didSet {
                if oldValue != subframes { subframes_Validate() }
            }
        }
        
        private mutating func subframes_Validate() {
            subframes = subframes.clamped(to: 0 ... 99)
        }
        
        public var frameRate: MIDIFile.SMPTEOffsetFrameRate = .fps30
        
        /// Returns a new `Timecode` instance from the SMPTE offset.
        public var components: Timecode.Components {
            .init(
                h: Int(hours),
                m: Int(minutes),
                s: Int(seconds),
                f: Int(frames),
                sf: Int(subframes)
            )
        }
        
        /// Returns a new `Timecode` instance from the SMPTE offset.
        public var timecode: Timecode {
            Timecode(
                .components(components),
                at: frameRate.timecodeRate,
                base: .max100SubFrames,
                by: .allowingInvalid
            )
        }
        
        // MARK: - Init
        
        init() { }
        
        init(
            hr: UInt8,
            min: UInt8,
            sec: UInt8,
            fr: UInt8,
            subFr: UInt8 = 0,
            frRate: MIDIFile.SMPTEOffsetFrameRate = .fps30
        ) {
            frameRate = frRate // enum, no validation needed
            
            hours = hr; hours_Validate()
            minutes = min; minutes_Validate()
            seconds = sec; seconds_Validate()
            frames = fr; frames_Validate()
            subframes = subFr; subframes_Validate()
        }
        
        init(scaling timecode: Timecode) {
            let smpteTCAndRate = timecode.scaledToMIDIFileSMPTEFrameRate
            
            let smpteTC = smpteTCAndRate.scaledTimecode
                ?? Timecode(.zero, at: timecode.frameRate) // 00:00:00:00 default
            
            frameRate = smpteTCAndRate.smpteFR
            
            hours =     UInt8(exactly: smpteTC.hours) ?? 0
            minutes =   UInt8(exactly: smpteTC.minutes) ?? 0
            seconds =   UInt8(exactly: smpteTC.seconds) ?? 0
            frames =    UInt8(exactly: smpteTC.frames) ?? 0
            subframes = UInt8(exactly: smpteTC.subFrames) ?? 0
        }
        
        // TODO: add an init from Timecode struct that can convert/scale timecode and subframes to 100 subframe divisor
    }
}

// MARK: - Static Constructors

extension MIDIFileEvent {
    /// Specify the SMPTE time at which the track is to start.
    /// This optional event, if present, should occur at the start of a track,
    /// at `time == 0`, and prior to any MIDI events.
    /// Defaults to `00:00:00:00 @ 24fps`.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > MIDI SMPTE Offset subframes (fractional frames) are always in 100ths of a frame, even in
    /// > SMPTE-based tracks which specify a different frame subdivision for delta-times.
    public static func smpteOffset(
        delta: DeltaTime = .none,
        hr: UInt8,
        min: UInt8,
        sec: UInt8,
        fr: UInt8,
        subFr: UInt8,
        frRate: MIDIFile.SMPTEOffsetFrameRate = .fps30
    ) -> Self {
        .smpteOffset(
            delta: delta,
            event: .init(
                hr: hr,
                min: min,
                sec: sec,
                fr: fr,
                subFr: subFr,
                frRate: frRate
            )
        )
    }
    
    /// Specify the SMPTE time at which the track is to start.
    /// This optional event, if present, should occur at the start of a track,
    /// at `time == 0`, and prior to any MIDI events.
    /// Defaults to `00:00:00:00 @ 24fps`.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > MIDI SMPTE Offset subframes (fractional frames) are always in 100ths of a frame, even in
    /// > SMPTE-based tracks which specify a different frame subdivision for delta-times.
    public static func smpteOffset(
        delta: DeltaTime = .none,
        scaling: Timecode
    ) -> Self {
        .smpteOffset(
            delta: delta,
            event: .init(scaling: scaling)
        )
    }
}

// MARK: - Encoding

extension MIDIFileEvent.SMPTEOffset: MIDIFileEventPayload {
    public static let smfEventType: MIDIFileEventType = .smpteOffset
    
    public init(midi1SMFRawBytes rawBytes: some DataProtocol) throws {
        guard rawBytes.count == Self.midi1SMFFixedRawBytesLength else {
            throw MIDIFile.DecodeError.malformed(
                "Invalid number of bytes. Expected \(Self.midi1SMFFixedRawBytesLength) but got \(rawBytes.count)"
            )
        }
        
        try rawBytes.withDataReader { dataReader in
            // 3-byte preamble
            guard try dataReader.read(bytes: 3).elementsEqual(
                MIDIFile.kEventHeaders[Self.smfEventType]!
            ) else {
                throw MIDIFile.DecodeError.malformed(
                    "Event does not start with expected bytes."
                )
            }
        
            let readHoursByte = try dataReader.readByte()
            let readFrameRateBits = (readHoursByte & 0b1100000) >> 5
            let readHours = readHoursByte & 0b0011111
        
            let readMinutes = try dataReader.readByte()
            let readSeconds = try dataReader.readByte()
            let readFrames = try dataReader.readByte()
            let readSubframes = try dataReader.readByte()
        
            guard let readFrameRate = MIDIFile.SMPTEOffsetFrameRate(rawValue: readFrameRateBits)
            else {
                // this should never happen, but trap error any way
                throw MIDIFile.DecodeError.malformed(
                    "Could not form frame rate from Hours byte."
                )
            }
        
            guard (0 ... 23).contains(readHours) else {
                throw MIDIFile.DecodeError.malformed(
                    "Hours is out of bounds: \(readHours)"
                )
            }
        
            guard (0 ... 59).contains(readMinutes) else {
                throw MIDIFile.DecodeError.malformed(
                    "Minutes is out of bounds: \(readMinutes)"
                )
            }
        
            guard (0 ... 59).contains(readSeconds) else {
                throw MIDIFile.DecodeError.malformed(
                    "Seconds value is out of bounds: \(readSeconds)"
                )
            }
        
            guard (0 ... 30).contains(readFrames) else {
                throw MIDIFile.DecodeError.malformed(
                    "Frames value is out of bounds: \(readFrames)"
                )
            }
        
            guard (0 ... 99).contains(readSubframes) else {
                throw MIDIFile.DecodeError.malformed(
                    "Subframes value is out of bounds: \(readSubframes)"
                )
            }
        
            frameRate = readFrameRate
        
            hours = readHours
            minutes = readMinutes
            seconds = readSeconds
            frames = readFrames
            subframes = readSubframes
        }
    }
    
    public func midi1SMFRawBytes<D: MutableDataProtocol>() -> D {
        // FF 54 05 hr mn se fr ff
        //
        // 05 is length
        //
        // hr is a byte specifying the hour, which is also encoded with the SMPTE format (frame
        // rate), just as it is in MIDI Time Code
        //   8 bits: 0rrhhhhh, where:
        //     - rr = frame rate:
        //       00 = 24 fps
        //       01 = 25 fps
        //       10 = 30 fps (drop frame)
        //       11 = 30 fps (non-drop frame)
        //     - hhhhh = hour (0-23)
        //
        // ff is a byte specifying the number of fractional frames, in 100ths of a frame (even in
        // SMPTE-based tracks using a different frame subdivision, defined in the MThd chunk).
        
        var data = D()
        
        data += MIDIFile.kEventHeaders[.smpteOffset]! // start bytes
        data += [(frameRate.rawValue << 5) + hours] // hour & frame rate
        data += [minutes] // minutes
        data += [seconds] // seconds
        data += [frames] // frames
        data += [subframes] // subframes
        
        return data
    }
    
    static let midi1SMFFixedRawBytesLength = 8
    
    public static func initFrom(
        midi1SMFRawBytesStream stream: some DataProtocol
    ) throws -> StreamDecodeResult {
        let requiredData = stream.prefix(midi1SMFFixedRawBytesLength)
        
        guard requiredData.count == midi1SMFFixedRawBytesLength else {
            throw MIDIFile.DecodeError.malformed(
                "Unexpected byte length."
            )
        }
        
        let newInstance = try Self(midi1SMFRawBytes: requiredData)
        
        return (
            newEvent: newInstance,
            bufferLength: midi1SMFFixedRawBytesLength
        )
    }
    
    public var smfDescription: String {
        let time =
            hours.string(paddedTo: 1) + ":" +
            minutes.string(paddedTo: 2) + ":" +
            seconds.string(paddedTo: 2) + ":" +
            frames.string(paddedTo: 2) + "." +
            subframes.string +
            " @ \(frameRate)"
        
        return "smpte: " + time
    }
    
    public var smfDebugDescription: String {
        "SMPTEOffset(" + smfDescription + ")"
    }
}

// MARK: - Helpers

extension Timecode {
    /// Determines the best corresponding MIDI File SMPTE Offset frame rate to represent this
    /// timecode, converts the timecode to that frame rate, and converts the subframes to be scaled
    /// to a 100 subframe divisor if needed.
    ///
    /// > Standard MIDI File 1.0 Spec:
    /// >
    /// > MIDI SMPTE Offset subframes (fractional frames) are always in 100ths of a frame, even in
    /// > SMPTE- based tracks which specify a different frame subdivision for delta-times.
    public var scaledToMIDIFileSMPTEFrameRate: (
        scaledTimecode: Timecode?,
        smpteFR: MIDIFile.SMPTEOffsetFrameRate
    ) {
        let midiFileSMPTEFrameRate = frameRate.midiFileSMPTEOffsetRate
        
        var scaledTC = try? converted(to: midiFileSMPTEFrameRate.timecodeRate)
        
        // scale subframes if needed
        if scaledTC?.subFramesBase != .max100SubFrames,
           let nonNilscaledTC = scaledTC
        {
            let originalSF = Double(nonNilscaledTC.subFrames)
            let originalSFD = Double(nonNilscaledTC.subFramesBase.rawValue)
            
            let scaledSubFrames =
                Int((originalSF / originalSFD) * 100)
            
            var newComponents = nonNilscaledTC.components
            newComponents.subFrames = scaledSubFrames
            
            scaledTC = try? Timecode(
                .components(newComponents),
                at: nonNilscaledTC.frameRate,
                base: .max100SubFrames
            )
        }
        
        // no match
        return (scaledTimecode: scaledTC, smpteFR: midiFileSMPTEFrameRate)
    }
}

extension TimecodeFrameRate {
    /// Returns the best corresponding MIDI File SMPTE Offset frame rate to represent the timecode
    /// frame rate.
    public var midiFileSMPTEOffsetRate: MIDIFile.SMPTEOffsetFrameRate {
        switch self {
        case .fps23_976: return .fps24 // as output from Pro Tools
        case .fps24: return .fps24 // as output from Pro Tools
        case .fps24_98: return .fps24 // custom
        case .fps25: return .fps25 // as output from Pro Tools
        case .fps29_97: return .fps30 // as output from Pro Tools
        case .fps29_97d: return .fps29_97d // as output from Pro Tools
        case .fps30: return .fps30 // as output from Pro Tools
        case .fps30d: return .fps29_97d // as output from Pro Tools
        case .fps47_952: return .fps24 // as output from Pro Tools
        case .fps48: return .fps24 // as output from Pro Tools
        case .fps50: return .fps25 // custom
        case .fps59_94: return .fps30 // custom
        case .fps59_94d: return .fps29_97d // custom
        case .fps60: return .fps30 // custom
        case .fps60d: return .fps29_97d // custom
        case .fps95_904: return .fps24 // custom
        case .fps96: return .fps24 // custom
        case .fps100: return .fps25 // custom
        case .fps119_88: return .fps30 // custom
        case .fps119_88d: return .fps29_97d // custom
        case .fps120: return .fps30 // custom
        case .fps120d: return .fps29_97d // custom
        }
    }
}

extension MIDIFile.SMPTEOffsetFrameRate {
    /// Returns exact `Timecode` frame rate that matches the MIDI File SMPTE Offset frame rate.
    public var timecodeRate: TimecodeFrameRate {
        switch self {
        case .fps24: return .fps24
        case .fps25: return .fps25
        case .fps29_97d: return .fps29_97d
        case .fps30: return .fps30
        }
    }
}
