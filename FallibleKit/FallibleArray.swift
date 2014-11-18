//
//  FallibleArray.swift
//  FallibleKit
//
//  Created by Brent Royal-Gordon on 11/18/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

public enum FallibleError: Int {
    public static var Domain = "FallibleKit"
    public static var DetailedErrorsKey = "NSDetailedErrors"
    
    case MultipleErrors = 1560
    case NoneSuccessful = 1
    
    var localizedDescription: String {
        switch self {
        case .MultipleErrors:
            return NSLocalizedString("Several operations failed.", comment: "")
        case .NoneSuccessful:
            return NSLocalizedString("No operations succeeded.", comment: "")
        }
    }
    
    static func errorsFromError(error: NSError) -> [NSError] {
        if error.domain == Domain {
            if let code = FallibleError(rawValue: error.code) {
                switch code {
                case .MultipleErrors:
                    return error.userInfo![DetailedErrorsKey] as [NSError]
                case .NoneSuccessful:
                    return []
                }
            }
        }
        return [error]
    }
    
    static func errorFromErrors(errors: [NSError]) -> NSError {
        var flatErrors = reduce(lazy(errors).map(errorsFromError), [], +)
        
        var code: FallibleError
        var userInfo: [String: AnyObject] = [:]
        
        switch flatErrors.count {
        case 0:
            code = .NoneSuccessful
        case 1:
            return flatErrors.first!
        default:
            code = .MultipleErrors
            userInfo[DetailedErrorsKey] = flatErrors
        }
        
        userInfo[NSLocalizedDescriptionKey] = code.localizedDescription
        return NSError(domain: Domain, code: code.rawValue, userInfo: userInfo)
    }
}

public func filterFailures<T>(array: [Fallible<T>]) -> [T] {
    return (anySucceeded(array) => recover { _ in Fallible(succeeded: []) }).value!
}

public func classifyFallibles<T>(array: [Fallible<T>]) -> (successes: [T], failures: [NSError]) {
    return reduce(array, (successes: [] as [T], failures: [] as [NSError])) { (tuple, elem) in
        if let value = elem.value {
            return (successes: tuple.successes + [value], failures: tuple.failures)
        }
        else {
            return (successes: tuple.successes, failures: tuple.failures + [elem.error!])
        }
    }
}

public func allSucceeded<T>(array: [Fallible<T>]) -> Fallible<[T]> {
    let (successes, failures) = classifyFallibles(array)
    if failures.isEmpty {
        return Fallible(succeeded: successes)
    }
    else {
        return Fallible(failed: FallibleError.errorFromErrors(failures))
    }
}

public func anySucceeded<T>(array: [Fallible<T>]) -> Fallible<[T]> {
    let (successes, failures) = classifyFallibles(array)
    if successes.isEmpty {
        return Fallible(failed: FallibleError.errorFromErrors(failures))
    }
    else {
        return Fallible(succeeded: successes)
    }
}
