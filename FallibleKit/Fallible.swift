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
public enum Fallible<ResultType>: CustomStringConvertible {
    case Success (ResultType)
    case Failure (ErrorType)
    
    /// Constructs a successful Fallible result, hiding the ugliness of the internal 
    /// `Reference` (which is needed to avoid a feature that Swift 1.1 doesn't 
    /// implement).
    public init(succeeded value: ResultType) {
        self = .Success(value)
    }
    
    /// Constructs a failed Fallible result. This is a good place to drop a 
    /// breakpoint if you're trying to find the source of a failure.
    public init(failed error: ErrorType) {
        self = .Failure(error)
    }
    
    /// Constructs a Fallible result from a Swift throwing operation.
    public init(@autoclosure catches operation: Void throws -> ResultType) {
        do {
            self.init(succeeded: try operation())
        }
        catch {
            self.init(failed: error)
        }
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
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the error if the Fallible operation failed, or nil if it succeeded.
    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
    
    public var description: String {
        switch self {
        case .Success(let value):
            return "Success(\(value))"
        case .Failure(let error):
            return "Failure(\(error))"
        }
    }
}
