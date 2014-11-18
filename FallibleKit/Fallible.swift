//
//  Fallible.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/3/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

import Foundation

/// Shorthand for a successful Fallible<Void>, which is awkward to construct 
/// normally.
public let Succeeded = Fallible<Void>(succeeded: ())

/// Represents the result of an operation which may succeed or fail. Upon success, 
/// a Fallible<T> contains a `value` of type T; upon failure, it contains an `error` 
/// of type NSError.
/// 
/// Note that, for various technical reasons, you generally shouldn't construct a 
/// Fallible using `Fallible.Success` and `Fallible.Failure`; instead use the 
/// `init(succeeded:)` and `init(failed:)` initializers.
public enum Fallible<ResultType>: Printable {
    case Success (Reference<ResultType>)
    case Failure (NSError)
    
    /// Constructs a successful Fallible result, hiding the ugliness of the internal 
    /// `Reference` (which is needed to avoid a feature that Swift 1.1 doesn't 
    /// implement).
    public init(succeeded value: ResultType) {
        self = .Success(Reference(value))
    }
    
    /// Constructs a failed Fallible result. This is a good place to drop a 
    /// breakpoint if you're trying to find the source of a failure.
    public init(failed error: NSError) {
        self = .Failure(error)
    }
        
    /// Returns true if the operation succeeded.
    public var succeeded: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    /// Returns true if the operation failed.
    public var failed: Bool {
        return !succeeded
    }
    
    /// Returns the value if the Fallible operation succeeded, or nil if it failed.
    public var value: ResultType? {
        switch self {
        case .Success(let reference):
            return reference.value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the error if the Fallible operation failed, or nil if it succeeded.
    public var error: NSError? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
    
    public var description: String {
        switch self {
        case .Success:
            return "Success(\(value!))"
        case .Failure(let error):
            return "Failure(\(error.domain)/\(error.code) \"\(error.localizedDescription)\" \(error.userInfo!))"
        }
    }
}

/// Wraps a possibly value type in an object. Used by Fallible to get around limits 
/// on generic enums.
public class Reference<T> {
    public let value: T
    
    public init(_ val: T) {
        value = val
    }
}

/// Constructs a Fallible result from the return value of a call with a 
/// Cocoa-style NSError parameter. This variant treats nil as the failure value.
public func toFallible<ResultType>(operation: (inout NSError?) -> ResultType?) -> Fallible<ResultType> {
    var error: NSError?
    if let result = operation(&error) {
        return Fallible(succeeded: result)
    }
    else {
        return Fallible(failed: error!)
    }
}

/// Constructs a Fallible result from the return value of a call with a 
/// Cocoa-style NSError parameter. This variant treats false as the failure value.
public func toFallible(operation: (inout NSError?) -> Bool) -> Fallible<Void> {
    var error: NSError?
    if operation(&error) {
        return Succeeded
    }
    else {
        return Fallible(failed: error!)
    }
}

/// Constructs a Fallible result from the return value of a call with a 
/// Cocoa-style NSError parameter. This variant allows you to specify the failure 
/// value.
public func toFallible<ResultType: Equatable>(failureValue: ResultType, operation: (inout NSError?) -> ResultType) -> Fallible<ResultType> {
    var error: NSError?
    let result = operation(&error)
    if result != failureValue {
        return Fallible(succeeded: result)
    }
    else {
        return Fallible(failed: error!)
    }
}
