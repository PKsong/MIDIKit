//
//  HUISurfaceModelNotification.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

import MIDIKitCore

/// Notification returned as a result of updating ``HUISurfaceModel`` state. Strongly-typed event
/// abstractions representing each control and display element of a HUI control surface along with
/// its new state value.
public enum HUISurfaceModelNotification {
    // MARK: Ping
    
    /// HUI ping event.
    case ping
    
    // MARK: Text Displays
    
    /// Large text display.
    ///
    /// - Parameters:
    ///   - top: String representing top row.
    ///   - bottom: String representing bottom row.
    case largeDisplay(
        top: HUILargeDisplayString,
        bottom: HUILargeDisplayString
    )
    
    /// Time display.
    ///
    /// - Parameters:
    ///   - timeString: String representing the full text read-out.
    case timeDisplay(timeString: HUITimeDisplayString)
    
    /// An LED changed near the time display.
    case timeDisplayStatus(
        param: HUISwitch.TimeDisplayStatus,
        state: Bool
    )
    
    /// Select Assign text display.
    ///
    /// - Parameters:
    ///   - text: text string
    case selectAssignDisplay(text: HUISmallDisplayString)
        
    // MARK: Channel Strips
    
    /// A channel strip-related element.
    ///
    /// - Parameters:
    ///   - channel: channel strip `0 ... 7`
    ///   - param: enum describing what control was changed
    case channelStrip(
        channel: UInt4,
        ChannelStripComponent
    )
    
    // MARK: Switches
    
    /// Keyboard hotkeys.
    case hotKey(param: HUISwitch.HotKey, state: Bool)
    
    /// Param Edit section.
    case paramEdit(ParamEditComponent)
    
    /// Function keys (to the right of the channel strips).
    case functionKey(param: HUISwitch.FunctionKey, state: Bool)
    
    /// Auto Enable section (to the right of the channel strips).
    case autoEnable(param: HUISwitch.AutoEnable, state: Bool)
    
    /// Auto Mode section (to the right of the channel strips).
    case autoMode(param: HUISwitch.AutoMode, state: Bool)
    
    /// Status/Group section (to the right of the channel strips).
    case statusAndGroup(param: HUISwitch.StatusAndGroup, state: Bool)
    
    /// Edit section (to the right of the channel strips).
    case edit(param: HUISwitch.Edit, state: Bool)
    
    /// Numeric entry pad.
    case numPad(param: HUISwitch.NumPad, state: Bool)
    
    /// Window functions.
    case window(param: HUISwitch.Window, state: Bool)
    
    /// Bank and channel navigation.
    case bankMove(param: HUISwitch.BankMove, state: Bool)
    
    /// Assign section (buttons to top left of channel strips).
    case assign(param: HUISwitch.Assign, state: Bool)
    
    /// Cursor Movement / Mode / Scrub / Shuttle.
    case cursor(param: HUISwitch.Cursor, state: Bool)
    
    /// Control Room section.
    case controlRoom(param: HUISwitch.ControlRoom, state: Bool)
    
    /// Transport section.
    case transport(param: HUISwitch.Transport, state: Bool)
    
    /// Footswitches and Sounds - no LEDs or buttons associated.
    case footswitchesAndSounds(param: HUISwitch.FootswitchesAndSounds, state: Bool)
    
    // MARK: Unhandled
    
    /// Undefined/unrecognized switch.
    case undefinedSwitch(
        zone: HUIZone,
        port: HUIPort,
        state: Bool
    )
}

extension HUISurfaceModelNotification: Equatable { }

extension HUISurfaceModelNotification: Hashable { }

extension HUISurfaceModelNotification: Sendable { }

extension HUISurfaceModelNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ping:
            return "ping"
            
        case let .largeDisplay(top: top, bottom: bottom):
            return "largeDisplay(top: \(top), bottom: \(bottom))"
            
        case let .timeDisplay(timeString: timeString):
            return "timeDisplay(\(timeString))"
            
        case let .timeDisplayStatus(param: param, state: state):
            return "timeDisplayStatus(\(param), state: \(state))"
            
        case let .selectAssignDisplay(text: text):
            return "selectAssignDisplay(\(text))"
            
        case let .channelStrip(channel: channel, component):
            return "channelStrip(channel: \(channel), \(component))"
            
        case let .hotKey(param: param, state: state):
            return "hotKey(\(param), state: \(state))"
            
        case let .paramEdit(param):
            return "paramEdit(\(param))"
            
        case let .functionKey(param: param, state: state):
            return "functionKey(\(param), state: \(state))"
            
        case let .autoEnable(param: param, state: state):
            return "autoEnable(\(param), state: \(state))"
            
        case let .autoMode(param: param, state: state):
            return "autoMode(\(param), state: \(state))"
            
        case let .statusAndGroup(param: param, state: state):
            return "statusAndGroup(\(param), state: \(state))"
            
        case let .edit(param: param, state: state):
            return "edit(\(param), state: \(state))"
            
        case let .numPad(param: param, state: state):
            return "numPad(\(param), state: \(state))"
            
        case let .window(param: param, state: state):
            return "window(\(param), state: \(state))"
            
        case let .bankMove(param: param, state: state):
            return "bankMove(\(param), state: \(state))"
            
        case let .assign(param: param, state: state):
            return "assign(\(param), state: \(state))"
            
        case let .cursor(param: param, state: state):
            return "cursor(\(param), state: \(state))"
            
        case let .controlRoom(param: param, state: state):
            return "controlRoom(\(param), state: \(state))"
            
        case let .transport(param: param, state: state):
            return "transport(\(param), state: \(state))"
            
        case let .footswitchesAndSounds(param: param, state: state):
            return "footswitchesAndSounds(\(param), state: \(state))"
            
        case let .undefinedSwitch(zone: zone, port: port, state: state):
            let z = zone.hexString(padTo: 2, prefix: true)
            let p = port.hexString(padTo: 1, prefix: true)
            return "undefinedSwitch(zone: \(z), port: \(p), state: \(state))"
        }
    }
}
