//
//  SysExManufacturer.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension MIDIEvent {
    /// Type representing a Manufacturer System Exclusive ID
    ///
    /// > MIDI 1.0 Spec:
    /// >
    /// > - To avoid conflicts with non-compatible Exclusive messages, a specific ID number is
    /// >   granted to manufacturers of MIDI instruments by the MMA or JMSC.
    /// >
    /// > - `[0x00]` and `[0x00 0x00 0x00]` are not to be used. Special ID `0x7D` is reserved for
    /// >   non-commercial use (e.g. schools, research, etc.) and is not to be used on any product
    /// >   released to the public. Since Non-Commercial codes would not be seen or used by an
    /// >   ordinary user, there is no standard format.
    /// >
    /// > - Special IDs `0x7E` and `0x7F` are the Universal System Exclusive IDs.
    ///
    /// For these special IDs, use MIDIKit's ``UniversalSysEx7`` type instead of ``SysEx7``.
    public enum SysExManufacturer: Equatable, Hashable {
        /// Valid range: `0x01 ... 0x7D`
        ///
        /// `0x00` is reserved to prefix a 2-byte ID (3 total bytes)
        case oneByte(UInt7)

        /// Valid range for bytes 2 & 3: `0x00 ... 0x7F`
        ///
        /// Byte 1 is always `0x00` and is therefore omitted from the tuple.
        case threeByte(byte2: UInt7, byte3: UInt7)
    }
}

extension MIDIEvent.SysExManufacturer: Sendable { }

extension MIDIEvent.SysExManufacturer {
    /// Initialize from a MIDI 1.0 SysEx7 ID (one or three bytes).
    public init?(sysEx7RawBytes: [UInt8]) {
        switch sysEx7RawBytes.count {
        case 1:
            switch sysEx7RawBytes[0] {
            case 0x00:
                // 0x00 is invalid if no bytes follow
                return nil
    
            case 0x01 ... 0x7D:
                self = .oneByte(sysEx7RawBytes[0].toUInt7)
                return
    
            case 0x7E, 0x7F:
                // reserved for Universal Sys Ex, not valid manufacturer IDs
                return nil
    
            default: // 0x80...
                // top bit set is invalid; malformed
                return nil
            }
    
        case 3:
            guard sysEx7RawBytes[0] == 0x00 else { return nil }
    
            guard let byte2 = UInt7(exactly: sysEx7RawBytes[1]),
                  let byte3 = UInt7(exactly: sysEx7RawBytes[2])
            else { return nil }
    
            self = .threeByte(byte2: byte2, byte3: byte3)
            return
    
        default:
            return nil
        }
    }
    
    /// Initialize from a MIDI 2.0 SysEx8 ID (two bytes).
    public init?(sysEx8RawBytes: [UInt8]) {
        guard sysEx8RawBytes.count == 2 else { return nil }
    
        switch sysEx8RawBytes[0] {
        case 0x00: // "one byte" ID
            // 0x00 is not valid for one-byte ID
            guard sysEx8RawBytes[1] > 0x00 else { return nil }
    
            // 0x7E and 0x7F are reserved for Universal SysEx
            guard sysEx8RawBytes[1] < 0x7E else { return nil }
    
            guard let byte = UInt7(exactly: sysEx8RawBytes[1]) else { return nil }
            self = .oneByte(byte)
            return
    
        case 0x80...: // "three byte" ID
            let byte2 = (sysEx8RawBytes[0] & 0b01111111).toUInt7
            guard let byte3 = UInt7(exactly: sysEx8RawBytes[1]) else { return nil }
            self = .threeByte(byte2: byte2, byte3: byte3)
    
        default:
            return nil
        }
    }
}

extension MIDIEvent.SysExManufacturer {
    /// Returns the Manufacturer byte(s) formatted for MIDI 1.0 SysEx7, as one byte (7-bit) or three
    /// bytes (21-bit).
    public func sysEx7RawBytes() -> [UInt8] {
        switch self {
        case let .oneByte(byte):
            return [byte.uInt8Value]
    
        case let .threeByte(byte2: byte2, byte3: byte3):
            return [0x00, byte2.uInt8Value, byte3.uInt8Value]
        }
    }
    
    /// Returns the Manufacturer byte(s) formatted for MIDI 2.0 SysEx8, as two bytes (16-bit).
    public func sysEx8RawBytes() -> [UInt8] {
        switch self {
        case let .oneByte(byte):
            return [0x00, byte.uInt8Value]
    
        case let .threeByte(byte2: byte2, byte3: byte3):
            return [
                0b10000000 + byte2.uInt8Value,
                byte3.uInt8Value
            ]
        }
    }
}

extension MIDIEvent.SysExManufacturer {
    /// Returns whether the byte(s) are valid SysEx Manufacturer IDs.
    ///
    /// This does not test whether the ID belongs to a registered manufacturer. Rather, it simply
    /// reports if the bytes are legal.
    ///
    /// Use the ``name`` property to return the manufacturer's name associated with the ID, or `nil`
    /// if the ID is not registered.
    public var isValid: Bool {
        switch self {
        case let .oneByte(byte):
            return (0x01 ... 0x7D).contains(byte)
    
        case let .threeByte(byte2: byte2, byte3: byte3):
            // both can't be 0x00, at least one has to be non-zero.
            // all other scenarios are valid
            return !(byte2 == 0x00 && byte3 == 0x00)
        }
    }
    
    /// Returns the name of the manufacturer associated with the Manufacturer System Exclusive ID,
    /// as assigned by the MIDI Manufacturers Association.
    ///
    /// Returns `nil` if the ID is not recognized.
    public var name: String? {
        Self.kSysExIDs
            .first(where: { $0.key == sysEx7RawBytes() })?
            .value
    }
}

extension MIDIEvent.SysExManufacturer: CustomStringConvertible {
    public var description: String {
        sysEx7RawBytes().hexString(padEachTo: 2, prefixes: true)
    }
}

extension MIDIEvent.SysExManufacturer {
    /// Returns a new instance containing the Educational Use ID.
    ///
    /// - Note: Reserved for use only in educational institutions or for unit testing; not public
    /// release.
    public static func educational() -> Self {
        .oneByte(0x7D)
    }
}

extension MIDIEvent.SysExManufacturer {
    // Data updated as of March 2021
    // source: https://www.midi.org/specifications-old/item/manufacturer-id-numbers

    /// Lookup table for Manufacturer MIDI SysEx (system exclusive) IDs assigned by the MIDI
    /// Manufacturers Association.
    ///
    /// (IDs can be either 1 or 3 bytes long.)
    static let kSysExIDs: [[UInt8]: String] = [
        // MARK: Special IDs

        [0x7D]: "-", // used for Educational Use or for unit testing, not public release
        
        // MARK: North American Group

        // 0x00 is Used for ID extensions and is not a valid 1-byte ID
        [0x01]: "Sequential Circuits",
        [0x02]: "IDP",
        [0x03]: "Voyetra Turtle Beach, Inc.",
        [0x04]: "Moog Music",
        [0x05]: "Passport Designs",
        [0x06]: "Lexicon Inc.",
        [0x07]: "Kurzweil / Young Chang",
        [0x08]: "Fender",
        [0x09]: "MIDI9",
        [0x0A]: "AKG Acoustics",
        [0x0B]: "Voyce Music",
        [0x0C]: "WaveFrame (Timeline)",
        [0x0D]: "ADA Signal Processors, Inc.",
        [0x0E]: "Garfield Electronics",
        [0x0F]: "Ensoniq",
        [0x10]: "Oberheim / Gibson Labs",
        [0x11]: "Apple",
        [0x12]: "Grey Matter Response",
        [0x13]: "Digidesign Inc. / Avid",
        [0x14]: "Palmtree Instruments",
        [0x15]: "JLCooper Electronics",
        [0x16]: "Lowrey Organ Company",
        [0x17]: "Adams-Smit",
        [0x18]: "E-mu",
        [0x19]: "Harmony Systems",
        [0x1A]: "ART",
        [0x1B]: "Baldwin",
        [0x1C]: "Eventide",
        [0x1D]: "Inventronics",
        [0x1E]: "Key Concepts",
        [0x1F]: "Clarity",
        [0x20]: "Passac",
        [0x21]: "Proel Labs (SIEL)",
        [0x22]: "Synthaxe (UK)",
        [0x23]: "Stepp",
        [0x24]: "Hohner",
        [0x25]: "Twister",
        [0x26]: "Ketron s.r.l.",
        [0x27]: "Jellinghaus MS",
        [0x28]: "Southworth Music Systems",
        [0x29]: "PPG (Germany)",
        [0x2A]: "JEN",
        [0x2B]: "Solid State Logic Organ Systems",
        [0x2C]: "Audio Veritrieb-P. Struven",
        [0x2D]: "Neve",
        [0x2E]: "Soundtracs Ltd.",
        [0x2F]: "Elka",
        [0x30]: "Dynacord",
        [0x31]: "Viscount International Spa (Intercontinental Electronics)",
        [0x32]: "Drawmer",
        [0x33]: "Clavia Digital Instruments",
        [0x34]: "Audio Architecture",
        [0x35]: "Generalmusic Corp SpA",
        [0x36]: "Cheetah Marketing",
        [0x37]: "C.T.M.",
        [0x38]: "Simmons UK",
        [0x39]: "Soundcraft Electronics",
        [0x3A]: "Steinberg Media Technologies Gmb",
        [0x3B]: "Wersi Gmb",
        [0x3C]: "AVAB Niethammer AB",
        [0x3D]: "Digigram",
        [0x3E]: "Waldorf Electronics Gmb",
        [0x3F]: "Quasimidi",
        // 0x40H...0x5F // [Assigned by AMEI for Japanese Manufacturers]
        // 0x60H...0x7F // [Reserved for Other Uses]
        [0x00, 0x00, 0x01]: "Time/Warner Interactive",
        [0x00, 0x00, 0x02]: "Advanced Gravis Comp. Tech Ltd.",
        [0x00, 0x00, 0x03]: "Media Vision",
        [0x00, 0x00, 0x04]: "Dornes Research Group",
        [0x00, 0x00, 0x05]: "K-Muse",
        [0x00, 0x00, 0x06]: "Stypher",
        [0x00, 0x00, 0x07]: "Digital Music Corp.",
        [0x00, 0x00, 0x08]: "IOTA Systems",
        [0x00, 0x00, 0x09]: "New England Digital",
        [0x00, 0x00, 0x0A]: "Artisyn",
        [0x00, 0x00, 0x0B]: "IVL Technologies Ltd.",
        [0x00, 0x00, 0x0C]: "Southern Music Systems",
        [0x00, 0x00, 0x0D]: "Lake Butler Sound Company",
        [0x00, 0x00, 0x0E]: "Alesis Studio Electronics",
        [0x00, 0x00, 0x0F]: "Sound Creation",
        [0x00, 0x00, 0x10]: "DOD Electronics Corp.",
        [0x00, 0x00, 0x11]: "Studer-Editech",
        [0x00, 0x00, 0x12]: "Sonus",
        [0x00, 0x00, 0x13]: "Temporal Acuity Products",
        [0x00, 0x00, 0x14]: "Perfect Fretworks",
        [0x00, 0x00, 0x15]: "KAT Inc.",
        [0x00, 0x00, 0x16]: "Opcode Systems",
        [0x00, 0x00, 0x17]: "Rane Corporation",
        [0x00, 0x00, 0x18]: "Anadi Electronique",
        [0x00, 0x00, 0x19]: "KMX",
        [0x00, 0x00, 0x1A]: "Allen & Heath Brenell",
        [0x00, 0x00, 0x1B]: "Peavey Electronics",
        [0x00, 0x00, 0x1C]: "360 Systems",
        [0x00, 0x00, 0x1D]: "Spectrum Design and Development",
        [0x00, 0x00, 0x1E]: "Marquis Music",
        [0x00, 0x00, 0x1F]: "Zeta Systems",
        [0x00, 0x00, 0x20]: "Axxes (Brian Parsonett)",
        [0x00, 0x00, 0x21]: "Orban",
        [0x00, 0x00, 0x22]: "Indian Valley Mfg.",
        [0x00, 0x00, 0x23]: "Triton",
        [0x00, 0x00, 0x24]: "KTI",
        [0x00, 0x00, 0x25]: "Breakaway Technologies",
        [0x00, 0x00, 0x26]: "Leprecon / CAE Inc.",
        [0x00, 0x00, 0x27]: "Harrison Systems Inc.",
        [0x00, 0x00, 0x28]: "Future Lab/Mark Kuo",
        [0x00, 0x00, 0x29]: "Rocktron Corporation",
        [0x00, 0x00, 0x2A]: "PianoDisc",
        [0x00, 0x00, 0x2B]: "Cannon Research Group",
        [0x00, 0x00, 0x2C]: "Reserved",
        [0x00, 0x00, 0x2D]: "Rodgers Instrument LLC",
        [0x00, 0x00, 0x2E]: "Blue Sky Logic",
        [0x00, 0x00, 0x2F]: "Encore Electronics",
        [0x00, 0x00, 0x30]: "Uptown",
        [0x00, 0x00, 0x31]: "Voce",
        [0x00, 0x00, 0x32]: "CTI Audio, Inc. (Musically Intel. Devs.)",
        [0x00, 0x00, 0x33]: "S3 Incorporated",
        [0x00, 0x00, 0x34]: "Broderbund / Red Orb",
        [0x00, 0x00, 0x35]: "Allen Organ Co.",
        [0x00, 0x00, 0x36]: "Reserved",
        [0x00, 0x00, 0x37]: "Music Quest",
        [0x00, 0x00, 0x38]: "Aphex",
        [0x00, 0x00, 0x39]: "Gallien Krueger",
        [0x00, 0x00, 0x3A]: "IBM",
        [0x00, 0x00, 0x3B]: "Mark Of The Unicorn",
        [0x00, 0x00, 0x3C]: "Hotz Corporation",
        [0x00, 0x00, 0x3D]: "ETA Lighting",
        [0x00, 0x00, 0x3E]: "NSI Corporation",
        [0x00, 0x00, 0x3F]: "Ad Lib, Inc.",
        [0x00, 0x00, 0x40]: "Richmond Sound Design",
        [0x00, 0x00, 0x41]: "Microsoft",
        [0x00, 0x00, 0x42]: "Mindscape (Software Toolworks)",
        [0x00, 0x00, 0x43]: "Russ Jones Marketing / Niche",
        [0x00, 0x00, 0x44]: "Intone",
        [0x00, 0x00, 0x45]: "Advanced Remote Technologies",
        [0x00, 0x00, 0x46]: "White Instruments",
        [0x00, 0x00, 0x47]: "GT Electronics/Groove Tubes",
        [0x00, 0x00, 0x48]: "Pacific Research & Engineering",
        [0x00, 0x00, 0x49]: "Timeline Vista, Inc.",
        [0x00, 0x00, 0x4A]: "Mesa Boogie Ltd.",
        [0x00, 0x00, 0x4B]: "FSLI",
        [0x00, 0x00, 0x4C]: "Sequoia Development Group",
        [0x00, 0x00, 0x4D]: "Studio Electronics",
        [0x00, 0x00, 0x4E]: "Euphonix, Inc",
        [0x00, 0x00, 0x4F]: "InterMIDI, Inc.",
        [0x00, 0x00, 0x50]: "MIDI Solutions Inc.",
        [0x00, 0x00, 0x51]: "3DO Company",
        [0x00, 0x00, 0x52]: "Lightwave Research / High End Systems",
        [0x00, 0x00, 0x53]: "Micro-W Corporation",
        [0x00, 0x00, 0x54]: "Spectral Synthesis, Inc.",
        [0x00, 0x00, 0x55]: "Lone Wolf",
        [0x00, 0x00, 0x56]: "Studio Technologies Inc.",
        [0x00, 0x00, 0x57]: "Peterson Electro-Musical Product, Inc.",
        [0x00, 0x00, 0x58]: "Atari Corporation",
        [0x00, 0x00, 0x59]: "Marion Systems Corporation",
        [0x00, 0x00, 0x5A]: "Design Event",
        [0x00, 0x00, 0x5B]: "Winjammer Software Ltd.",
        [0x00, 0x00, 0x5C]: "AT&T Bell Laboratories",
        [0x00, 0x00, 0x5D]: "Reserved",
        [0x00, 0x00, 0x5E]: "Symetrix",
        [0x00, 0x00, 0x5F]: "MIDI the World",
        [0x00, 0x00, 0x60]: "Spatializer",
        [0x00, 0x00, 0x61]: "Micros 'N MIDI",
        [0x00, 0x00, 0x62]: "Accordians International",
        [0x00, 0x00, 0x63]: "EuPhonics (now 3Com)",
        [0x00, 0x00, 0x64]: "Musonix",
        [0x00, 0x00, 0x65]: "Turtle Beach Systems (Voyetra)",
        [0x00, 0x00, 0x66]: "Loud Technologies / Mackie",
        [0x00, 0x00, 0x67]: "Compuserve",
        [0x00, 0x00, 0x68]: "BEC Technologies",
        [0x00, 0x00, 0x69]: "QRS Music Inc",
        [0x00, 0x00, 0x6A]: "P.G. Music",
        [0x00, 0x00, 0x6B]: "Sierra Semiconductor",
        [0x00, 0x00, 0x6C]: "EpiGraf",
        [0x00, 0x00, 0x6D]: "Electronics Diversified Inc",
        [0x00, 0x00, 0x6E]: "Tune 1000",
        [0x00, 0x00, 0x6F]: "Advanced Micro Devices",
        [0x00, 0x00, 0x70]: "Mediamation",
        [0x00, 0x00, 0x71]: "Sabine Musical Mfg. Co. Inc.",
        [0x00, 0x00, 0x72]: "Woog Labs",
        [0x00, 0x00, 0x73]: "Micropolis Corp",
        [0x00, 0x00, 0x74]: "Ta Horng Musical Instrument",
        [0x00, 0x00, 0x75]: "e-Tek Labs (Forte Tech)",
        [0x00, 0x00, 0x76]: "Electro-Voice",
        [0x00, 0x00, 0x77]: "Midisoft Corporation",
        [0x00, 0x00, 0x78]: "QSound Labs",
        [0x00, 0x00, 0x79]: "Westrex",
        [0x00, 0x00, 0x7A]: "Nvidia",
        [0x00, 0x00, 0x7B]: "ESS Technology",
        [0x00, 0x00, 0x7C]: "Media Trix Peripherals",
        [0x00, 0x00, 0x7D]: "Brooktree Corp",
        [0x00, 0x00, 0x7E]: "Otari Corp",
        [0x00, 0x00, 0x7F]: "Key Electronics, Inc.",
        [0x00, 0x01, 0x00]: "Shure Incorporated",
        [0x00, 0x01, 0x01]: "AuraSound",
        [0x00, 0x01, 0x02]: "Crystal Semiconductor",
        [0x00, 0x01, 0x03]: "Conexant (Rockwell)",
        [0x00, 0x01, 0x04]: "Silicon Graphics",
        [0x00, 0x01, 0x05]: "M-Audio (Midiman)",
        [0x00, 0x01, 0x06]: "PreSonus",
        [0x00, 0x01, 0x08]: "Topaz Enterprises",
        [0x00, 0x01, 0x09]: "Cast Lighting",
        [0x00, 0x01, 0x0A]: "Microsoft Consumer Division",
        [0x00, 0x01, 0x0B]: "Sonic Foundry",
        [0x00, 0x01, 0x0C]: "Line 6 (Fast Forward) (Yamaha)",
        [0x00, 0x01, 0x0D]: "Beatnik Inc",
        [0x00, 0x01, 0x0E]: "Van Koevering Company",
        [0x00, 0x01, 0x0F]: "Altech Systems",
        [0x00, 0x01, 0x10]: "S & S Research",
        [0x00, 0x01, 0x11]: "VLSI Technology",
        [0x00, 0x01, 0x12]: "Chromatic Research",
        [0x00, 0x01, 0x13]: "Sapphire",
        [0x00, 0x01, 0x14]: "IDRC",
        [0x00, 0x01, 0x15]: "Justonic Tuning",
        [0x00, 0x01, 0x16]: "TorComp Research Inc.",
        [0x00, 0x01, 0x17]: "Newtek Inc.",
        [0x00, 0x01, 0x18]: "Sound Sculpture",
        [0x00, 0x01, 0x19]: "Walker Technical",
        [0x00, 0x01, 0x1A]: "Digital Harmony (PAVO)",
        [0x00, 0x01, 0x1B]: "InVision Interactive",
        [0x00, 0x01, 0x1C]: "T-Square Design",
        [0x00, 0x01, 0x1D]: "Nemesys Music Technology",
        [0x00, 0x01, 0x1E]: "DBX Professional (Harman Intl)",
        [0x00, 0x01, 0x1F]: "Syndyne Corporation",
        [0x00, 0x01, 0x20]: "Bitheadz",
        [0x00, 0x01, 0x21]: "BandLab Technologies",
        [0x00, 0x01, 0x22]: "Analog Devices",
        [0x00, 0x01, 0x23]: "National Semiconductor",
        [0x00, 0x01, 0x24]: "Boom Theory / Adinolfi Alternative Percussion",
        [0x00, 0x01, 0x25]: "Virtual DSP Corporation",
        [0x00, 0x01, 0x26]: "Antares Systems",
        [0x00, 0x01, 0x27]: "Angel Software",
        [0x00, 0x01, 0x28]: "St Louis Music",
        [0x00, 0x01, 0x29]: "Passport Music Software LLC (Gvox)",
        [0x00, 0x01, 0x2A]: "Ashley Audio Inc.",
        [0x00, 0x01, 0x2B]: "Vari-Lite Inc.",
        [0x00, 0x01, 0x2C]: "Summit Audio Inc.",
        [0x00, 0x01, 0x2D]: "Aureal Semiconductor Inc.",
        [0x00, 0x01, 0x2E]: "SeaSound LLC",
        [0x00, 0x01, 0x2F]: "U.S. Robotics",
        [0x00, 0x01, 0x30]: "Aurisis Research",
        [0x00, 0x01, 0x31]: "Nearfield Research",
        [0x00, 0x01, 0x32]: "FM7 Inc",
        [0x00, 0x01, 0x33]: "Swivel Systems",
        [0x00, 0x01, 0x34]: "Hyperactive Audio Systems",
        [0x00, 0x01, 0x35]: "MidiLite (Castle Studios Productions)",
        [0x00, 0x01, 0x36]: "Radikal Technologies",
        [0x00, 0x01, 0x37]: "Roger Linn Design",
        [0x00, 0x01, 0x38]: "TC-Helicon Vocal Technologies",
        [0x00, 0x01, 0x39]: "Event Electronics",
        [0x00, 0x01, 0x3A]: "Sonic Network Inc",
        [0x00, 0x01, 0x3B]: "Realtime Music Solutions",
        [0x00, 0x01, 0x3C]: "Apogee Digital",
        [0x00, 0x01, 0x3D]: "Classical Organs, Inc.",
        [0x00, 0x01, 0x3E]: "Microtools Inc.",
        [0x00, 0x01, 0x3F]: "Numark Industries",
        [0x00, 0x01, 0x40]: "Frontier Design Group, LLC",
        [0x00, 0x01, 0x41]: "Recordare LLC",
        [0x00, 0x01, 0x42]: "Starr Labs",
        [0x00, 0x01, 0x43]: "Voyager Sound Inc.",
        [0x00, 0x01, 0x44]: "Manifold Labs",
        [0x00, 0x01, 0x45]: "Aviom Inc.",
        [0x00, 0x01, 0x46]: "Mixmeister Technology",
        [0x00, 0x01, 0x47]: "Notation Software",
        [0x00, 0x01, 0x48]: "Mercurial Communications",
        [0x00, 0x01, 0x49]: "Wave Arts",
        [0x00, 0x01, 0x4A]: "Logic Sequencing Devices",
        [0x00, 0x01, 0x4B]: "Axess Electronics",
        [0x00, 0x01, 0x4C]: "Muse Research",
        [0x00, 0x01, 0x4D]: "Open Labs",
        [0x00, 0x01, 0x4E]: "Guillemot Corp",
        [0x00, 0x01, 0x4F]: "Samson Technologies",
        [0x00, 0x01, 0x50]: "Electronic Theatre Controls",
        [0x00, 0x01, 0x51]: "Blackberry (RIM)",
        [0x00, 0x01, 0x52]: "Mobileer",
        [0x00, 0x01, 0x53]: "Synthogy",
        [0x00, 0x01, 0x54]: "Lynx Studio Technology Inc.",
        [0x00, 0x01, 0x55]: "Damage Control Engineering LLC",
        [0x00, 0x01, 0x56]: "Yost Engineering, Inc.",
        [0x00, 0x01, 0x57]: "Brooks & Forsman Designs LLC / DrumLite",
        [0x00, 0x01, 0x58]: "Infinite Response",
        [0x00, 0x01, 0x59]: "Garritan Corp",
        [0x00, 0x01, 0x5A]: "Plogue Art et Technologie, Inc",
        [0x00, 0x01, 0x5B]: "RJM Music Technology",
        [0x00, 0x01, 0x5C]: "Custom Solutions Software",
        [0x00, 0x01, 0x5D]: "Sonarcana LLC / Highly Liquid",
        [0x00, 0x01, 0x5E]: "Centrance",
        [0x00, 0x01, 0x5F]: "Kesumo LLC",
        [0x00, 0x01, 0x60]: "Stanton (Gibson Brands)",
        [0x00, 0x01, 0x61]: "Livid Instruments",
        [0x00, 0x01, 0x62]: "First Act / 745 Media",
        [0x00, 0x01, 0x63]: "Pygraphics, Inc.",
        [0x00, 0x01, 0x64]: "Panadigm Innovations Ltd",
        [0x00, 0x01, 0x65]: "Avedis Zildjian Co",
        [0x00, 0x01, 0x66]: "Auvital Music Corp",
        [0x00, 0x01, 0x67]: "You Rock Guitar (was: Inspired Instruments)",
        [0x00, 0x01, 0x68]: "Chris Grigg Designs",
        [0x00, 0x01, 0x69]: "Slate Digital LLC",
        [0x00, 0x01, 0x6A]: "Mixware",
        [0x00, 0x01, 0x6B]: "Social Entropy",
        [0x00, 0x01, 0x6C]: "Source Audio LLC",
        [0x00, 0x01, 0x6D]: "Ernie Ball / Music Man",
        [0x00, 0x01, 0x6E]: "Fishman",
        [0x00, 0x01, 0x6F]: "Custom Audio Electronics",
        [0x00, 0x01, 0x70]: "American Audio/DJ",
        [0x00, 0x01, 0x71]: "Mega Control Systems",
        [0x00, 0x01, 0x72]: "Kilpatrick Audio",
        [0x00, 0x01, 0x73]: "iConnectivity",
        [0x00, 0x01, 0x74]: "Fractal Audio",
        [0x00, 0x01, 0x75]: "NetLogic Microsystems",
        [0x00, 0x01, 0x76]: "Music Computing",
        [0x00, 0x01, 0x77]: "Nektar Technology Inc",
        [0x00, 0x01, 0x78]: "Zenph Sound Innovations",
        [0x00, 0x01, 0x79]: "DJTechTools.com",
        [0x00, 0x01, 0x7A]: "Rezonance Labs",
        [0x00, 0x01, 0x7B]: "Decibel Eleven",
        [0x00, 0x01, 0x7C]: "CNMAT",
        [0x00, 0x01, 0x7D]: "Media Overkill",
        [0x00, 0x01, 0x7E]: "Confusion Studios",
        [0x00, 0x01, 0x7F]: "moForte Inc",
        [0x00, 0x02, 0x00]: "Miselu Inc",
        [0x00, 0x02, 0x01]: "Amelia's Compass LLC",
        [0x00, 0x02, 0x02]: "Zivix LLC",
        [0x00, 0x02, 0x03]: "Artiphon",
        [0x00, 0x02, 0x04]: "Synclavier Digital",
        [0x00, 0x02, 0x05]: "Light & Sound Control Devices LLC",
        [0x00, 0x02, 0x06]: "Retronyms Inc",
        [0x00, 0x02, 0x07]: "JS Technologies",
        [0x00, 0x02, 0x08]: "Quicco Sound",
        [0x00, 0x02, 0x09]: "A-Designs Audio",
        [0x00, 0x02, 0x0A]: "McCarthy Music Corp",
        [0x00, 0x02, 0x0B]: "Denon DJ",
        [0x00, 0x02, 0x0C]: "Keith Robert Murray",
        [0x00, 0x02, 0x0D]: "Google",
        [0x00, 0x02, 0x0E]: "ISP Technologies",
        [0x00, 0x02, 0x0F]: "Abstrakt Instruments LLC",
        [0x00, 0x02, 0x10]: "Meris LLC",
        [0x00, 0x02, 0x11]: "Sensorpoint LLC",
        [0x00, 0x02, 0x12]: "Hi-Z Labs",
        [0x00, 0x02, 0x13]: "Imitone",
        [0x00, 0x02, 0x14]: "Intellijel Designs Inc.",
        [0x00, 0x02, 0x15]: "Dasz Instruments Inc.",
        [0x00, 0x02, 0x16]: "Remidi",
        [0x00, 0x02, 0x17]: "Disaster Area Designs LLC",
        [0x00, 0x02, 0x18]: "Universal Audio",
        [0x00, 0x02, 0x19]: "Carter Duncan Corp",
        [0x00, 0x02, 0x1A]: "Essential Technology",
        [0x00, 0x02, 0x1B]: "Cantux Research LLC",
        [0x00, 0x02, 0x1C]: "Hummel Technologies",
        [0x00, 0x02, 0x1D]: "Sensel Inc",
        [0x00, 0x02, 0x1E]: "DBML Group",
        [0x00, 0x02, 0x1F]: "Madrona Labs",
        [0x00, 0x02, 0x20]: "Mesa Boogie",
        [0x00, 0x02, 0x21]: "Effigy Labs",
        [0x00, 0x02, 0x22]: "MK2 Image Ltd",
        [0x00, 0x02, 0x23]: "Red Panda LLC",
        [0x00, 0x02, 0x24]: "OnSong LLC",
        [0x00, 0x02, 0x25]: "Jamboxx Inc.",
        [0x00, 0x02, 0x26]: "Electro-Harmonix",
        [0x00, 0x02, 0x27]: "RnD64 Inc",
        [0x00, 0x02, 0x28]: "Neunaber Technology LLC",
        [0x00, 0x02, 0x29]: "Kaom Inc.",
        [0x00, 0x02, 0x2A]: "Hallowell EMC",
        [0x00, 0x02, 0x2B]: "Sound Devices, LLC",
        [0x00, 0x02, 0x2C]: "Spectrasonics, Inc",
        [0x00, 0x02, 0x2D]: "Second Sound, LLC",
        [0x00, 0x02, 0x2E]: "8eo (Horn)",
        [0x00, 0x02, 0x2F]: "VIDVOX LLC",
        [0x00, 0x02, 0x30]: "Matthews Effects",
        [0x00, 0x02, 0x31]: "Bright Blue Beetle",
        [0x00, 0x02, 0x32]: "Audio Impressions",
        [0x00, 0x02, 0x33]: "Looperlative",
        [0x00, 0x02, 0x34]: "Steinway",
        [0x00, 0x02, 0x35]: "Ingenious Arts and Technologies LLC",
        [0x00, 0x02, 0x36]: "DCA Audio",
        [0x00, 0x02, 0x37]: "Buchla USA",
        [0x00, 0x02, 0x38]: "Sinicon",
        [0x00, 0x02, 0x39]: "Isla Instruments",
        [0x00, 0x02, 0x3A]: "Soundiron LLC",
        [0x00, 0x02, 0x3B]: "Sonoclast, LLC",
        
        // MARK: European and 'Other' Group

        [0x00, 0x20, 0x00]: "Dream SAS",
        [0x00, 0x20, 0x01]: "Strand Lighting",
        [0x00, 0x20, 0x02]: "Amek Div of Harman Industries",
        [0x00, 0x20, 0x03]: "Casa Di Risparmio Di Loreto",
        [0x00, 0x20, 0x04]: "Böhm electronic GmbH",
        [0x00, 0x20, 0x05]: "Syntec Digital Audio",
        [0x00, 0x20, 0x06]: "Trident Audio Developments",
        [0x00, 0x20, 0x07]: "Real World Studio",
        [0x00, 0x20, 0x08]: "Evolution Synthesis, Ltd",
        [0x00, 0x20, 0x09]: "Yes Technology",
        [0x00, 0x20, 0x0A]: "Audiomatica",
        [0x00, 0x20, 0x0B]: "Bontempi SpA (Sigma)",
        [0x00, 0x20, 0x0C]: "F.B.T. Elettronica SpA",
        [0x00, 0x20, 0x0D]: "MidiTemp GmbH",
        [0x00, 0x20, 0x0E]: "LA Audio (Larking Audio)",
        [0x00, 0x20, 0x0F]: "Zero 88 Lighting Limited",
        [0x00, 0x20, 0x10]: "Micon Audio Electronics GmbH",
        [0x00, 0x20, 0x11]: "Forefront Technology",
        [0x00, 0x20, 0x12]: "Studio Audio and Video Ltd.",
        [0x00, 0x20, 0x13]: "Kenton Electronics",
        [0x00, 0x20, 0x14]: "Celco/ Electrosonic",
        [0x00, 0x20, 0x15]: "ADB",
        [0x00, 0x20, 0x16]: "Marshall Products Limited",
        [0x00, 0x20, 0x17]: "DDA",
        [0x00, 0x20, 0x18]: "BSS Audio Ltd.",
        [0x00, 0x20, 0x19]: "MA Lighting Technology",
        [0x00, 0x20, 0x1A]: "Fatar SRL c/o Music Industries",
        [0x00, 0x20, 0x1B]: "QSC Audio Products Inc.",
        [0x00, 0x20, 0x1C]: "Artisan Clasic Organ Inc.",
        [0x00, 0x20, 0x1D]: "Orla Spa",
        [0x00, 0x20, 0x1E]: "Pinnacle Audio (Klark Teknik PLC)",
        [0x00, 0x20, 0x1F]: "TC Electronics",
        [0x00, 0x20, 0x20]: "Doepfer Musikelektronik GmbH",
        [0x00, 0x20, 0x21]: "Creative ATC / E-mu",
        [0x00, 0x20, 0x22]: "Seyddo/Minami",
        [0x00, 0x20, 0x23]: "LG Electronics (Goldstar)",
        [0x00, 0x20, 0x24]: "Midisoft sas di M.Cima & C",
        [0x00, 0x20, 0x25]: "Samick Musical Inst. Co. Ltd.",
        [0x00, 0x20, 0x26]: "Penny and Giles (Bowthorpe PLC)",
        [0x00, 0x20, 0x27]: "Acorn Computer",
        [0x00, 0x20, 0x28]: "LSC Electronics Pty. Ltd.",
        [0x00, 0x20, 0x29]: "Focusrite/Novation",
        [0x00, 0x20, 0x2A]: "Samkyung Mechatronics",
        [0x00, 0x20, 0x2B]: "Medeli Electronics Co.",
        [0x00, 0x20, 0x2C]: "Charlie Lab SRL",
        [0x00, 0x20, 0x2D]: "Blue Chip Music Technology",
        [0x00, 0x20, 0x2E]: "BEE OH Corp",
        [0x00, 0x20, 0x2F]: "LG Semicon America",
        [0x00, 0x20, 0x30]: "TESI",
        [0x00, 0x20, 0x31]: "EMAGIC",
        [0x00, 0x20, 0x32]: "Behringer GmbH",
        [0x00, 0x20, 0x33]: "Access Music Electronics",
        [0x00, 0x20, 0x34]: "Synoptic",
        [0x00, 0x20, 0x35]: "Hanmesoft",
        [0x00, 0x20, 0x36]: "Terratec Electronic GmbH",
        [0x00, 0x20, 0x37]: "Proel SpA",
        [0x00, 0x20, 0x38]: "IBK MIDI",
        [0x00, 0x20, 0x39]: "IRCAM",
        [0x00, 0x20, 0x3A]: "Propellerhead Software",
        [0x00, 0x20, 0x3B]: "Red Sound Systems Ltd",
        [0x00, 0x20, 0x3C]: "Elektron ESI AB",
        [0x00, 0x20, 0x3D]: "Sintefex Audio",
        [0x00, 0x20, 0x3E]: "MAM (Music and More)",
        [0x00, 0x20, 0x3F]: "Amsaro GmbH",
        [0x00, 0x20, 0x40]: "CDS Advanced Technology BV (Lanbox)",
        [0x00, 0x20, 0x41]: "Mode Machines (Touched By Sound GmbH)",
        [0x00, 0x20, 0x42]: "DSP Arts",
        [0x00, 0x20, 0x43]: "Phil Rees Music Tech",
        [0x00, 0x20, 0x44]: "Stamer Musikanlagen GmbH",
        [0x00, 0x20, 0x45]: "Musical Muntaner S.A. dba Soundart",
        [0x00, 0x20, 0x46]: "C-Mexx Software",
        [0x00, 0x20, 0x47]: "Klavis Technologies",
        [0x00, 0x20, 0x48]: "Noteheads AB",
        [0x00, 0x20, 0x49]: "Algorithmix",
        [0x00, 0x20, 0x4A]: "Skrydstrup R&D",
        [0x00, 0x20, 0x4B]: "Professional Audio Company",
        [0x00, 0x20, 0x4C]: "NewWave Labs (MadWaves)",
        [0x00, 0x20, 0x4D]: "Vermona",
        [0x00, 0x20, 0x4E]: "Nokia",
        [0x00, 0x20, 0x4F]: "Wave Idea",
        [0x00, 0x20, 0x50]: "Hartmann GmbH",
        [0x00, 0x20, 0x51]: "Lion's Tracs",
        [0x00, 0x20, 0x52]: "Analogue Systems",
        [0x00, 0x20, 0x53]: "Focal-JMlab",
        [0x00, 0x20, 0x54]: "Ringway Electronics (Chang-Zhou) Co Ltd",
        [0x00, 0x20, 0x55]: "Faith Technologies (Digiplug)",
        [0x00, 0x20, 0x56]: "Showworks",
        [0x00, 0x20, 0x57]: "Manikin Electronic",
        [0x00, 0x20, 0x58]: "1 Come Tech",
        [0x00, 0x20, 0x59]: "Phonic Corp",
        [0x00, 0x20, 0x5A]: "Dolby Australia (Lake)",
        [0x00, 0x20, 0x5B]: "Silansys Technologies",
        [0x00, 0x20, 0x5C]: "Winbond Electronics",
        [0x00, 0x20, 0x5D]: "Cinetix Medien und Interface GmbH",
        [0x00, 0x20, 0x5E]: "A&G Soluzioni Digitali",
        [0x00, 0x20, 0x5F]: "Sequentix GmbH",
        [0x00, 0x20, 0x60]: "Oram Pro Audio",
        [0x00, 0x20, 0x61]: "Be4 Ltd",
        [0x00, 0x20, 0x62]: "Infection Music",
        [0x00, 0x20, 0x63]: "Central Music Co. (CME)",
        [0x00, 0x20, 0x64]: "genoQs Machines GmbH",
        [0x00, 0x20, 0x65]: "Medialon",
        [0x00, 0x20, 0x66]: "Waves Audio Ltd",
        [0x00, 0x20, 0x67]: "Jerash Labs",
        [0x00, 0x20, 0x68]: "Da Fact",
        [0x00, 0x20, 0x69]: "Elby Designs",
        [0x00, 0x20, 0x6A]: "Spectral Audio",
        [0x00, 0x20, 0x6B]: "Arturia",
        [0x00, 0x20, 0x6C]: "Vixid",
        [0x00, 0x20, 0x6D]: "C-Thru Music",
        [0x00, 0x20, 0x6E]: "Ya Horng Electronic Co LTD",
        [0x00, 0x20, 0x6F]: "SM Pro Audio",
        [0x00, 0x20, 0x70]: "OTO Machines",
        [0x00, 0x20, 0x71]: "ELZAB S.A. (G LAB)",
        [0x00, 0x20, 0x72]: "Blackstar Amplification Ltd",
        [0x00, 0x20, 0x73]: "M3i Technologies GmbH",
        [0x00, 0x20, 0x74]: "Gemalto (from Xiring)",
        [0x00, 0x20, 0x75]: "Prostage SL",
        [0x00, 0x20, 0x76]: "Teenage Engineering",
        [0x00, 0x20, 0x77]: "Tobias Erichsen Consulting",
        [0x00, 0x20, 0x78]: "Nixer Ltd",
        [0x00, 0x20, 0x79]: "Hanpin Electron Co Ltd",
        [0x00, 0x20, 0x7A]: "\"MIDI-hardware\" R.Sowa",
        [0x00, 0x20, 0x7B]: "Beyond Music Industrial Ltd",
        [0x00, 0x20, 0x7C]: "Kiss Box B.V.",
        [0x00, 0x20, 0x7D]: "Misa Digital Technologies Ltd",
        [0x00, 0x20, 0x7E]: "AI Musics Technology Inc",
        [0x00, 0x20, 0x7F]: "Serato Inc LP",
        [0x00, 0x21, 0x00]: "Limex",
        [0x00, 0x21, 0x01]: "Kyodday (Tokai)",
        [0x00, 0x21, 0x02]: "Mutable Instruments",
        [0x00, 0x21, 0x03]: "PreSonus Software Ltd",
        [0x00, 0x21, 0x04]: "Ingenico (was Xiring)",
        [0x00, 0x21, 0x05]: "Fairlight Instruments Pty Ltd",
        [0x00, 0x21, 0x06]: "Musicom Lab",
        [0x00, 0x21, 0x07]: "Modal Electronics (Modulus/VacoLoco)",
        [0x00, 0x21, 0x08]: "RWA (Hong Kong) Limited",
        [0x00, 0x21, 0x09]: "Native Instruments",
        [0x00, 0x21, 0x0A]: "Naonext",
        [0x00, 0x21, 0x0B]: "MFB",
        [0x00, 0x21, 0x0C]: "Teknel Research",
        [0x00, 0x21, 0x0D]: "Ploytec GmbH",
        [0x00, 0x21, 0x0E]: "Surfin Kangaroo Studio",
        [0x00, 0x21, 0x0F]: "Philips Electronics HK Ltd",
        [0x00, 0x21, 0x10]: "ROLI Ltd",
        [0x00, 0x21, 0x11]: "Panda-Audio Ltd",
        [0x00, 0x21, 0x12]: "BauM Software",
        [0x00, 0x21, 0x13]: "Machinewerks Ltd.",
        [0x00, 0x21, 0x14]: "Xiamen Elane Electronics",
        [0x00, 0x21, 0x15]: "Marshall Amplification PLC",
        [0x00, 0x21, 0x16]: "Kiwitechnics Ltd",
        [0x00, 0x21, 0x17]: "Rob Papen",
        [0x00, 0x21, 0x18]: "Spicetone OU",
        [0x00, 0x21, 0x19]: "V3Sound",
        [0x00, 0x21, 0x1A]: "IK Multimedia",
        [0x00, 0x21, 0x1B]: "Novalia Ltd",
        [0x00, 0x21, 0x1C]: "Modor Music",
        [0x00, 0x21, 0x1D]: "Ableton",
        [0x00, 0x21, 0x1E]: "Dtronics",
        [0x00, 0x21, 0x1F]: "ZAQ Audio",
        [0x00, 0x21, 0x20]: "Muabaobao Education Technology Co Ltd",
        [0x00, 0x21, 0x21]: "Flux Effects",
        [0x00, 0x21, 0x22]: "Audiothingies (MCDA)",
        [0x00, 0x21, 0x23]: "Retrokits",
        [0x00, 0x21, 0x24]: "Morningstar FX Pte Ltd",
        [0x00, 0x21, 0x25]: "Changsha Hotone Audio Co Ltd",
        [0x00, 0x21, 0x26]: "Expressive E",
        [0x00, 0x21, 0x27]: "Expert Sleepers Ltd",
        [0x00, 0x21, 0x28]: "Timecode-Vision Technology",
        [0x00, 0x21, 0x29]: "Hornberg Research GbR",
        [0x00, 0x21, 0x2A]: "Sonic Potions",
        [0x00, 0x21, 0x2B]: "Audiofront",
        [0x00, 0x21, 0x2C]: "Fred's Lab",
        [0x00, 0x21, 0x2D]: "Audio Modeling",
        [0x00, 0x21, 0x2E]: "C. Bechstein Digital GmbH",
        [0x00, 0x21, 0x2F]: "Motas Electronics Ltd",
        [0x00, 0x21, 0x30]: "Elk Audio",
        [0x00, 0x21, 0x31]: "Sonic Academy Ltd",
        [0x00, 0x21, 0x32]: "Bome Software",
        [0x00, 0x21, 0x33]: "AODYO SAS",
        [0x00, 0x21, 0x34]: "Pianoforce S.R.O",
        [0x00, 0x21, 0x35]: "Dreadbox P.C.",
        [0x00, 0x21, 0x36]: "TouchKeys Instruments Ltd",
        [0x00, 0x21, 0x37]: "The Gigrig Ltd",
        [0x00, 0x21, 0x38]: "ALM Co",
        [0x00, 0x21, 0x39]: "CH Sound Design",
        [0x00, 0x21, 0x3A]: "Beat Bars",
        [0x00, 0x21, 0x3B]: "Blokas",
        [0x00, 0x21, 0x3C]: "GEWA Music GmbH",
        [0x00, 0x21, 0x3D]: "dadamachines",
        [0x00, 0x21, 0x3E]: "Augmented Instruments Ltd (Bela)",
        [0x00, 0x21, 0x3F]: "Supercritical Ltd",
        [0x00, 0x21, 0x40]: "Genki Instruments",
        [0x00, 0x21, 0x41]: "Marienberg Devices Germany",
        [0x00, 0x21, 0x42]: "Supperware Ltd",
        [0x00, 0x21, 0x43]: "Imoxplus BVBA",
        [0x00, 0x21, 0x44]: "Swapp Technologies SRL",
        [0x00, 0x21, 0x45]: "Electra One S.R.O.",
        [0x00, 0x21, 0x46]: "Digital Clef Limited",
        [0x00, 0x21, 0x47]: "Paul Whittington Group Ltd",
        [0x00, 0x21, 0x48]: "Music Hackspace",
        [0x00, 0x21, 0x49]: "Bitwig GMBH",
        [0x00, 0x21, 0x4A]: "Enhancia",
        [0x00, 0x21, 0x4B]: "KV 331",
        [0x00, 0x21, 0x4C]: "Tehnicadelarte",
        [0x00, 0x21, 0x4D]: "Endlesss Studio",
        [0x00, 0x21, 0x4E]: "Dongguan MIDIPLUS Co., LTD",
        [0x00, 0x21, 0x4F]: "Gracely Pty Ltd.",
        [0x00, 0x21, 0x50]: "Embodme",
        [0x00, 0x21, 0x51]: "MuseScore",
        [0x00, 0x21, 0x52]: "EPFL (E-Lab)",
        [0x00, 0x21, 0x53]: "Orb3 Ltd.",
        [0x00, 0x21, 0x54]: "Pitch Innovations",
        [0x00, 0x21, 0x55]: "Playces",
        [0x00, 0x21, 0x56]: "UDO Audio LTD",
        [0x00, 0x21, 0x57]: "RSS Sound Design",
        [0x00, 0x21, 0x58]: "Nonlinear Labs GmbH",
        [0x00, 0x21, 0x59]: "Robkoo Information & Technologies Co., Ltd.",
        
        // MARK: Japanese Group
    
        [0x40]: "Kawai Musical Instruments MFG. CO. Ltd",
        [0x41]: "Roland Corporation",
        [0x42]: "Korg Inc.",
        [0x43]: "Yamaha Corporation",
        [0x44]: "Casio Computer Co. Ltd",
        [0x46]: "Kamiya Studio Co. Ltd",
        [0x47]: "Akai Electric Co. Ltd.",
        [0x48]: "Victor Company of Japan, Ltd.",
        [0x4B]: "Fujitsu Limited",
        [0x4C]: "Sony Corporation",
        [0x4E]: "Teac Corporation",
        [0x50]: "Matsushita Electric Industrial Co. , Ltd",
        [0x51]: "Fostex Corporation",
        [0x52]: "Zoom Corporation",
        [0x54]: "Matsushita Communication Industrial Co., Ltd.",
        [0x55]: "Suzuki Musical Instruments MFG. Co., Ltd.",
        [0x56]: "Fuji Sound Corporation Ltd.",
        [0x57]: "Acoustic Technical Laboratory, Inc.",
        [0x59]: "Faith, Inc.",
        [0x5A]: "Internet Corporation",
        [0x5C]: "Seekers Co. Ltd.",
        [0x5F]: "SD Card Association",
        
        [0x00, 0x40, 0x00]: "Crimson Technology Inc.",
        [0x00, 0x40, 0x01]: "Softbank Mobile Corp",
        [0x00, 0x40, 0x03]: "D&M Holdings Inc.",
        [0x00, 0x40, 0x04]: "Xing Inc.",
        [0x00, 0x40, 0x05]: "AlphaTheta Corporation",
        [0x00, 0x40, 0x06]: "Pioneer Corporation",
        [0x00, 0x40, 0x07]: "Slik Corporation",
        
        [0x00, 0x48, 0x00]: "sigboost Co., Ltd.",         // expiration date: 2021.50.30
        [0x00, 0x48, 0x01]: "Lost Technology",            // expiration date: 2021.06.19
        [0x00, 0x48, 0x02]: "Uchiwa Fujin",               // expiration date: 2021.06.30
        [0x00, 0x48, 0x03]: "Tsukuba Science Co., Ltd.",  // expiration date: 2021.10.04
        [0x00, 0x48, 0x04]: "Sonicware Co., Ltd.",        // expiration date: 2021.11.06
        [0x00, 0x48, 0x05]: "Poppy only workshop"         // expiration date: 2021.10.20
    ]
}
