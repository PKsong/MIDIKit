//
//  MTCDecoder.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

// Notes:
//
// Pro Tools
// ---------
// - Pro Tools (as of v2018.4) does not send any full frame messages.
// - Essentially, it does not send any location or relocation messages of any kind over MTC.
// - When normal playback begins (forwards in time, at 1:1 speed), PT starts transmitting
//   quarter-frames. When playback stops, it simply stops transmitting quarter-frames. It does not
//   complete a full frame before stopping MTC transmission, it will stop at the last quarter-frame
// - When half-speed playback starts (forwards in time, at half-speed), PT will transmit
//   quarter-frames as normal, but they will transmit at half the speed. This is not necessary meant
//   for the receiver to synchronize playback to, but to simply continue receiving timecode values
//   to update its timecode display.
// - Pro Tools is capable of forwards and backwards scrubbing at various speeds, but does not
//   transmit any MTC data while doing those operations.
//
// Cubase
// ------
// - Cubase Pro sends full frame messages.
//
// Logic Pro
// ---------
// - Logic Pro X (as of 10.4.1) does not send any full frame messages.
//

import Foundation
import MIDIKitCore
import MIDIKitIO
import TimecodeKitCore

/// MTC (MIDI Timecode) stream decoder object.
///
/// Takes a stream of MIDI events and produces timecode values.
///
/// This object is not affected by or reliant on timing at all and simply processes events as they
/// are received. For inbound MTC sync, use the ``MTCReceiver`` wrapper object which adds additional
/// abstraction for managing MTC sync state.
///
/// > Note:
/// >
/// > - A running MTC data stream (during playback) only updates the frame number every 2 frames, so
/// > this data stream should not be relied on for deriving exact frame position, but rather as a
/// > mechanism for displaying running timecode to the user on screen or synchronizing playback to
/// > the incoming MTC data stream.
/// >
/// > - MTC full frame messages (which only some DAWs support) will however transmit frame-accurate
/// > timecodes when scrubbing or locating to different times, but will be limited to the base frame
/// > rates supported by MTC.
public final class MTCDecoder: @unchecked Sendable { // @unchecked required for @ThreadSafeAccess use
    // MARK: - Public properties
    
    /// Last timecode formed from incoming MTC data.
    @ThreadSafeAccess
    public internal(set) var timecode = Timecode(.zero, at: .fps30, base: subFramesBase)
    
    /// The base MTC frame rate last received.
    @ThreadSafeAccess
    public internal(set) var mtcFrameRate: MTCFrameRate = .mtc30 {
        didSet {
            if mtcFrameRate != oldValue {
                mtcFrameRateChangedHandler?(mtcFrameRate)
            }
        }
    }
    
    /// The frame rate the local system is using.
    ///
    /// When set, MTC frame numbers will be scaled to real frame rate frame numbers, but only when
    /// the incoming MTC frame rate and the ``localFrameRate`` are compatible.
    ///
    /// Remember to also set this any time the local frame rate changes so the receiver can
    /// interpret the incoming MTC accordingly.
    @ThreadSafeAccess
    public var localFrameRate: TimecodeFrameRate?
    
    /// Status of the direction of MTC quarter-frames received
    @ThreadSafeAccess
    public internal(set) var direction: MTCDirection = .forwards
    
    // MARK: - Stored closures
    
    /// Called when a meaningful change to the timecode has occurred which would require its display
    /// to be updated.
    ///
    /// Implement this closure for when you only want to display timecode and do not need to sync to
    /// MTC.
    ///
    /// - Parameters:
    ///   - timecode: Current display timecode.
    ///   - event: The MTC event that triggered the callback.
    ///   - direction: The current MTC playback or scrub direction.
    ///   - isFrameChanged: Boolean indicating that there has been a change to the four main timecode
    ///     components (`HH:MM:SS:FF`, ignoring subframes) since the last time this callback was called.
    nonisolated(unsafe) var timecodeChangedHandler: (@Sendable (
        _ timecode: Timecode,
        _ event: MTCMessageType,
        _ direction: MTCDirection,
        _ isFrameChanged: Bool
    ) -> Void)?
    
    /// Sets the closure called when a meaningful change to the timecode has occurred which would
    /// require its display to be updated.
    ///
    /// Implement this closure for when you only want to display timecode and do not need to sync to
    /// MTC.
    ///
    /// - Parameters:
    ///   - handler: Closure containing the following parameters:
    ///     - `timecode`: Current display timecode.
    ///     - `event`: The MTC event that triggered the callback.
    ///     - `direction`: The current MTC playback or scrub direction.
    ///     - `isFrameChanged`: Boolean indicating that there has been a change to the four main timecode
    ///       components (`HH:MM:SS:FF`, ignoring subframes) since the last time this callback was called.
    public func setTimecodeChangedHandler(
        _ handler: (@Sendable (
            _ timecode: Timecode,
            _ event: MTCMessageType,
            _ direction: MTCDirection,
            _ isFrameChanged: Bool
        ) -> Void)?
    ) {
        timecodeChangedHandler = handler
    }
    
    /// Called only when the incoming MTC stream changes its frame rate classification.
    ///
    /// This can usually be ignored, as the ``MTCDecoder`` can handle scaling and validation of the
    /// frame rate information from the stream transparently.
    nonisolated(unsafe) var mtcFrameRateChangedHandler: (@Sendable (_ rate: MTCFrameRate) -> Void)?
    
    /// Sets the closure called only when the incoming MTC stream changes its frame rate
    /// classification.
    ///
    /// This can usually be ignored, as the ``MTCDecoder`` can handle scaling and validation of the
    /// frame rate information from the stream transparently.
    public func setMTCFrameRateChangedHandler(
        _ handler: (@Sendable (_ rate: MTCFrameRate) -> Void)?
    ) {
        mtcFrameRateChangedHandler = handler
    }
    
    // MARK: - Internal properties
    
    nonisolated static let subFramesBase: Timecode.SubFramesBase = .max100SubFrames
    
    // Quarter-Frame tracking registers
    
    nonisolated(unsafe) var TC_H_lsb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_H_msb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_M_lsb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_M_msb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_S_lsb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_S_msb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_F_lsb: UInt8 = 0b00000000
    nonisolated(unsafe) var TC_F_msb: UInt8 = 0b00000000
    
    nonisolated(unsafe) var TC_H_lsb_received = false
    nonisolated(unsafe) var TC_H_msb_received = false
    nonisolated(unsafe) var TC_M_lsb_received = false
    nonisolated(unsafe) var TC_M_msb_received = false
    nonisolated(unsafe) var TC_S_lsb_received = false
    nonisolated(unsafe) var TC_S_msb_received = false
    nonisolated(unsafe) var TC_F_lsb_received = false
    nonisolated(unsafe) var TC_F_msb_received = false
    
    nonisolated(unsafe) var quarterFrameBufferIsComplete = false
    nonisolated(unsafe) var lastQuarterFrameReceived: UInt8 = 0b000
    nonisolated(unsafe) var receivedSyncQFSinceQFBufferComplete = false
    
    nonisolated(unsafe) var rawHours = 0
    nonisolated(unsafe) var rawMinutes = 0
    nonisolated(unsafe) var rawSeconds = 0
    nonisolated(unsafe) var rawFrames = 0
    
    nonisolated(unsafe) var lastCapturedWholeTimecode: Timecode.Components = .zero
    nonisolated(unsafe) var lastCapturedWholeTimecodeDirection: MTCDirection = .ambiguous
    nonisolated(unsafe) var lastCapturedWholeTimecodeDeltaQFs: Int?
    nonisolated(unsafe) var lastTimecodeSentToHandler: Timecode.Components = .zero
    
    // MARK: - init
    
    /// Initialize a new MTC decoder object, optionally supplying initial local frame rate and
    /// callback handlers.
    ///
    /// - Parameters:
    ///   - initialLocalFrameRate: Initial local timecode frame rate (scaled from MTC timecode and
    ///     frame rate)
    ///   - timecodeChanged: Timecode changed callback handler. See ``setTimecodeChangedHandler(_:)``
    ///     for more information.
    ///   - mtcFrameRateChanged: Callback called when the incoming MTC stream changes its frame rate
    ///     classification. See ``setMTCFrameRateChangedHandler(_:)`` for more information.
    public init(
        initialLocalFrameRate: TimecodeFrameRate? = nil,
        timecodeChanged: (@Sendable (
            _ timecode: Timecode,
            _ event: MTCMessageType,
            _ direction: MTCDirection,
            _ isFrameChanged: Bool
        ) -> Void)? = nil,
        mtcFrameRateChanged: (@Sendable (_ rate: MTCFrameRate) -> Void)? = nil
    ) {
        // assign properties
        
        localFrameRate = initialLocalFrameRate
        if let localFrameRate { timecode.frameRate = localFrameRate }
        
        // handlers
        
        timecodeChangedHandler = timecodeChanged
        mtcFrameRateChangedHandler = mtcFrameRateChanged
    }
}

extension MTCDecoder: ReceivesMIDIEvents {
    // MARK: - ReceivesMIDIEvents
    
    /// Incoming MIDI messages
    public func midiIn(event: MIDIEvent) {
        switch event {
        case let .universalSysEx7(payload):
            processSysEx(
                universalType: payload.universalType,
                deviceID: payload.deviceID,
                subID1: payload.subID1,
                subID2: payload.subID2,
                data: payload.data
            )
            
        case let .timecodeQuarterFrame(payload):
            processQF(dataByte: payload.dataByte.uInt8Value)
            
        default:
            break
        }
    }
    
    /// MTC Full Timecode message
    /// (1-frame resolution, does not carry subframe information)
    /// ---------------------
    /// F0 7F 7F 01 01 hh mm ss ff F7
    ///
    /// hour byte includes base framerate info
    /// 0rrhhhhh: Rate (0–3) and hour (0–23).
    /// rr == 00: 24 frames/s
    /// rr == 01: 25 frames/s
    /// rr == 10: 29.97d frames/s (SMPTE drop-frame timecode)
    /// rr == 11: 30 frames/s
    func processSysEx(
        universalType: MIDIEvent.UniversalSysExType,
        deviceID: UInt7,
        subID1: UInt7,
        subID2: UInt7,
        data: [UInt8]
    ) {
        guard universalType == .realTime, // 0x7F
              deviceID      == 0x7F,
              subID1        == 0x01,
              subID2        == 0x01,
              data.count    == 4
        else { return }
        
        // fps component
        setMTCFrameRate(rateBits: (data[0] & 0b01100000) >> 5)
        
        // timecode components
        rawHours = Int(data[0] & 0b00011111) // mask to retrieve the last 5 bits (hour)
        rawMinutes = Int(data[1]) // literal integer
        rawSeconds = Int(data[2]) // literal integer
        rawFrames = Int(data[3]) // literal integer
        
        var tcc = Timecode.Components(
            h: rawHours,
            m: rawMinutes,
            s: rawSeconds,
            f: rawFrames
        )
        
        // set up a variable to store the actual output frame rate
        let outputFrameRate: TimecodeFrameRate
        
        // scale frames if local frame rate is set
        // scaling will return nil if frame rates are not compatible
        if let localFrameRate,
           let scaledFramesDouble = mtcFrameRate.scaledFrames(
            fromRawMTCFrames: tcc.frames,
            quarterFrames: 0,
            to: localFrameRate
           )
        {
            let scaledFrameInt = Int(scaledFramesDouble)
            tcc.frames = scaledFrameInt
            
            // since scaling succeeded, we know we are outputting the localFrameRate
            outputFrameRate = localFrameRate
        } else {
            outputFrameRate = mtcFrameRate.directEquivalentFrameRate
        }
        
        let tc = Timecode(.components(tcc), at: outputFrameRate, by: .allowingInvalid)
        
        // update raw timecode values property
        timecode = tc
        
        let isFrameChanged = !lastTimecodeSentToHandler.isEqualIgnoringSubFrames(to: tcc)
        
        lastTimecodeSentToHandler = tcc
        
        // notify handler that timecode has changed
        timecodeChangedHandler?(
            tc,
            .fullFrame,
            direction,
            isFrameChanged
        )
    }
    
    /// Quarter-frame messages
    /// ----------------------
    /// Since it takes eight quarter-frames for a complete time code message, the complete SMPTE
    /// time is updated every two frames.
    /// A quarter-frame message consists of a status byte of 0xF1, followed by a single 7-bit data
    /// value: 3 bits to identify the piece, and 4 bits of partial time code.
    func processQF(dataByte: UInt8) {
        // Verbose debugging - careful when enabling this!
        // -----------------------------------------------
        // print("F1",
        //
        // data[1]
        //     .binary.stringValue(padTo: 8),
        //
        // ((data[1] & 0b01110000) >> 4)
        //     .binary.stringValue(padTo: 3, prefix: true))
        // -----------------------------------------------
        
        // Quarter-frame messages are received in this order during playback.
        // Piece 0 is transmitted at the coded moment.
        // When time is running forward, the piece numbers increment from 0–7; with the time that
        // piece 0 is transmitted is the coded instant, and the remaining pieces are transmitted
        // later.
        // If rewinding, data is received in reverse order. Again, piece 0 is transmitted at the
        // coded moment.
        // Since 8 Quarter Frame messages are required to piece together the current SMPTE time,
        // timing lock can't be achieved until the slave has received all 8 messages. This will take
        // from 2 to 4 SMPTE Frames, depending upon when the slave comes online.
        // The Frame number (contained in the first 2 Quarter Frame messages) is the SMPTE Frames
        // Time for when the first Quarter Frame message is sent. But, because it takes 7 more
        // quarter-frames to piece together the current SMPTE Time, when the slave does finally
        // piece the time together, it is actually 2 SMPTE Frames behind the real current time. So,
        // for display purposes, the slave should always add 2 frames to the current time.
        //
        // Piece #  Data byte   Significance
        // -------  ---------   ------------
        // 0        0000 ffff   Frame number lsbits
        // 1        0001 000f   Frame number msbit
        // 2        0010 ssss   Seconds lsbits
        // 3        0011 00ss   Seconds msbits
        // 4        0100 mmmm   Minutes lsbits
        // 5        0101 00mm   Minutes msbits
        // 6        0110 hhhh   Hours lsbits
        // 7        0111 0rrh   Rate and hours msbit
        
        // update internal registers
        
        let quarterFrameReceived = (dataByte & 0b01110000) >> 4
        
        // quarter-frame direction
        direction = MTCDirection(
            previousQF: lastQuarterFrameReceived,
            newQF: quarterFrameReceived
        )
        
        // only update delta QFs if we can be assured we've already received a QF 0 capture
        if receivedSyncQFSinceQFBufferComplete {
            if lastCapturedWholeTimecodeDeltaQFs == nil { lastCapturedWholeTimecodeDeltaQFs = 0 }
            
            switch direction {
            case .forwards: lastCapturedWholeTimecodeDeltaQFs! += 1
            case .backwards: lastCapturedWholeTimecodeDeltaQFs! -= 1
            default: break
            }
        }
        
        switch quarterFrameReceived {
        case 0b000: // Frames number lsbits -- sync: frame 1 of 2
            TC_F_lsb = dataByte & 0b00001111
            if direction == .backwards {
                rawFrames = Int(TC_F_lsb) + Int(TC_F_msb << 4)
            }
            
            TC_F_lsb_received = true
            
            // capture full timecode if all 8 QFs have already been received in sequence
            if qfBufferComplete() {
                receivedSyncQFSinceQFBufferComplete = true
                
                if lastCapturedWholeTimecodeDeltaQFs == nil ||
                    lastCapturedWholeTimecodeDeltaQFs == 8 ||
                    lastCapturedWholeTimecodeDeltaQFs == -8
                {
                    lastCapturedWholeTimecode = .init(
                        h: rawHours,
                        m: rawMinutes,
                        s: rawSeconds,
                        f: rawFrames
                    )
                    
                    lastCapturedWholeTimecodeDirection = direction
                }
                
                lastCapturedWholeTimecodeDeltaQFs = 0
            }
            
        case 0b001: // Frames number msbit
            TC_F_msb = dataByte & 0b00000001
            if direction == .forwards {
                rawFrames = Int(TC_F_lsb) + Int(TC_F_msb << 4)
            }
            TC_F_msb_received = true
            
        case 0b010: // Seconds lsbits
            TC_S_lsb = dataByte & 0b00001111
            if direction == .backwards {
                rawSeconds = Int(TC_S_lsb) + Int(TC_S_msb << 4)
            }
            TC_S_lsb_received = true
            
        case 0b011: // Seconds msbits
            TC_S_msb = dataByte & 0b00000011
            if direction == .forwards {
                rawSeconds = Int(TC_S_lsb) + Int(TC_S_msb << 4)
            }
            TC_S_msb_received = true
            
        case 0b100: // Minutes lsbits -- sync: frame 2 of 2
            TC_M_lsb = dataByte & 0b00001111
            if direction == .backwards {
                rawMinutes = Int(TC_M_lsb) + Int(TC_M_msb << 4)
            }
            TC_M_lsb_received = true
            
        case 0b101: // Minutes msbits
            TC_M_msb = dataByte & 0b00000011
            if direction == .forwards {
                rawMinutes = Int(TC_M_lsb) + Int(TC_M_msb << 4)
            }
            TC_M_msb_received = true
            
        case 0b110: // Hours lsbits
            TC_H_lsb = dataByte & 0b00001111
            if direction == .backwards {
                rawHours = Int(TC_H_lsb) + Int(TC_H_msb << 4)
            }
            TC_H_lsb_received = true
            
        case 0b111: // Rate and Hours msbit
            TC_H_msb = dataByte & 0b00000001
            if direction == .forwards {
                rawHours = Int(TC_H_lsb) + Int(TC_H_msb << 4)
            }
            TC_H_msb_received = true
            
            setMTCFrameRate(rateBits: (dataByte & 0b00000110) >> 1)
            
        default:
            // this should never happen (all possible 3-bit value cases are covered)
            break
        }
        
        // update registers
        lastQuarterFrameReceived = quarterFrameReceived
        
        // all 8 QFs must be received to ascertain a full SMTPE timecode
        // however, do not update timecode until sync QF is reached
        if qfBufferComplete(),
           receivedSyncQFSinceQFBufferComplete
        {
            var tcc = lastCapturedWholeTimecode
            
            guard let lastCapturedWholeTimecodeDeltaQFs
            else {
                preconditionFailure("lastCapturedWholeTimecodeDeltaQFs should not be nil.")
            }
            
            // perform 2-frame offsets depending on direction
            if lastCapturedWholeTimecodeDeltaQFs >= 0,
               lastCapturedWholeTimecodeDirection != .backwards
            {
                if let tc = try? Timecode(.components(tcc), at: mtcFrameRate.directEquivalentFrameRate, base: Self.subFramesBase)
                    .adding(.components(f: 2), by: .wrapping)
                {
                    tcc = tc.components
                }
            } else if lastCapturedWholeTimecodeDeltaQFs < 0,
                      lastCapturedWholeTimecodeDirection == .backwards
            {
                if let tc = try? Timecode(.components(tcc), at: mtcFrameRate.directEquivalentFrameRate, base: Self.subFramesBase)
                    .subtracting(.components(f: 2), by: .wrapping)
                {
                    tcc = tc.components
                }
            }
            
            // set up a variable to store the actual output frame rate
            let outputFrameRate: TimecodeFrameRate
            
            // scale or interpolate based on if local frame rate is set
            // scaling will return nil if frame rates are not compatible
            if let localFrameRate,
               let scaledFramesDouble = mtcFrameRate.scaledFrames(
                fromRawMTCFrames: tcc.frames,
                quarterFrames: quarterFrameReceived,
                to: localFrameRate
               )
            {
                // frames:
                let scaledFramesInt = Int(scaledFramesDouble)
                tcc.frames = scaledFramesInt
                
                // subframes:
                // assumes a hard-coded subframes base of 100 subframes per frame
                let scaledSubFramesInt = Int((scaledFramesDouble - Double(scaledFramesInt)) * 100)
                tcc.subFrames = scaledSubFramesInt
                
                // since scaling succeeded, we know we are outputting the localFrameRate
                outputFrameRate = localFrameRate
            } else {
                // use raw MTC frames and interpolate to produce sequential frame numbers
                
                // if sync QF 2 of 2 or thereafter
                if quarterFrameReceived >= 0b100 {
                    // interpolation: artificially increment MTC frames by 1
                    tcc.frames += 1
                }
                
                // subframes:
                // assumes a hard-coded subframes base of 100 subframes per frame
                tcc.subFrames = (Int(quarterFrameReceived - (quarterFrameReceived >= 0b100 ? 0b100 : 0)) * 100) / 4
                
                // we're outputting the direct equivalent of the MTC stream's frame rate
                outputFrameRate = mtcFrameRate.directEquivalentFrameRate
            }
            
            let tc = Timecode(.components(tcc), at: outputFrameRate, base: Self.subFramesBase, by: .allowingInvalid)
            
            // set local timecode property
            timecode = tc
            
            let isFrameChanged = !lastTimecodeSentToHandler.isEqualIgnoringSubFrames(to: tcc)
            
            lastTimecodeSentToHandler = tcc
            
            // notify handler timecode has changed at this exact moment
            timecodeChangedHandler?(
                tc,
                .quarterFrame,
                direction,
                isFrameChanged
            )
        }
    }
    
    /// Internal:
    /// Parses frame rate info received from MTC stream and stores value.
    /// - Parameter rateBits: two-bit number
    func setMTCFrameRate(rateBits: UInt8) {
        if let bits = MTCFrameRate(rateBits) {
            mtcFrameRate = bits
        }
    }
    
    /// Internal:
    /// Returns true if all 8 quarter-frames have been received in order to assemble a full MTC
    /// timecode.
    func qfBufferComplete() -> Bool {
        // return cached true value
        if quarterFrameBufferIsComplete { return true }
        
        // ... otherwise, compute:
        let requisiteIsMet =
        TC_H_lsb_received &&
        TC_H_msb_received &&
        TC_M_lsb_received &&
        TC_M_msb_received &&
        TC_S_lsb_received &&
        TC_S_msb_received &&
        TC_F_lsb_received &&
        TC_F_msb_received
        
        // set cached value only if true
        if requisiteIsMet { quarterFrameBufferIsComplete = true }
        
        return requisiteIsMet
    }
    
    /// Flushes internal quarter-frame receive registers.
    ///
    /// You may want to call this, for example, when QF stream is lost or interrupted.
    ///
    /// Flushing the registers will ensure that the next quarter-frame stream received is treated as
    /// a new stream and can avoid forming nonsense timecodes prior to receiving the full 8
    /// quarter-frames.
    public func resetQFBuffer() {
        TC_H_lsb_received = false
        TC_H_msb_received = false
        TC_M_lsb_received = false
        TC_M_msb_received = false
        TC_S_lsb_received = false
        TC_S_msb_received = false
        TC_F_lsb_received = false
        TC_F_msb_received = false
        
        quarterFrameBufferIsComplete = false
        lastQuarterFrameReceived = 0b000
        receivedSyncQFSinceQFBufferComplete = false
        
        lastCapturedWholeTimecode = .init(h: 0, m: 0, s: 0, f: 0)
        lastCapturedWholeTimecodeDirection = .ambiguous
        lastTimecodeSentToHandler = .init(h: 0, m: 0, s: 0, f: 0)
        lastCapturedWholeTimecodeDeltaQFs = nil
    }
    
    /// Manually resets internal timecode values back to default: 00:00:00:00
    public func resetTimecodeValues() {
        rawHours = 0
        rawMinutes = 0
        rawSeconds = 0
        rawFrames = 0
        
        timecode = Timecode(
            .zero,
            at: localFrameRate ?? mtcFrameRate.directEquivalentFrameRate,
            base: Self.subFramesBase
        )
    }
}

// MARK: - Helpers

extension Timecode.Components {
    func isEqualIgnoringSubFrames(to other: Timecode.Components) -> Bool {
        days == other.days &&
            hours == other.hours &&
            minutes == other.minutes &&
            seconds == other.seconds &&
            frames == other.frames
    }
}
