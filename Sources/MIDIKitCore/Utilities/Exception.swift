//
//  Exception.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// Raises an `NSException`
@inlinable
func raiseException(
    _ exceptionName: NSExceptionName,
    reason: String? = nil
) {
    let exception = NSException(name: exceptionName, reason: reason, userInfo: nil)
    exception.raise()
}

/// Pre-formed `NSException` cases.
@usableFromInline
enum Exception {
    case overflow
    case underflow
    case divisionByZero
    
    @inlinable
    func raise(reason: String? = nil) {
        switch self {
        case .overflow:
            raiseException(.decimalNumberOverflowException, reason: reason)
    
        case .underflow:
            raiseException(.decimalNumberUnderflowException, reason: reason)
    
        case .divisionByZero:
            raiseException(.decimalNumberDivideByZeroException, reason: reason)
        }
    }
}
