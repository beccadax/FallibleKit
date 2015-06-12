//
//  ErrorSet.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/15/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

import Foundation

/// An ErrorSet represents a particular set of NSError domains and codes within 
/// those domains. ErrorSet itself has no public API, but you can use the 
/// `error(domain:code:)` and `errors(domain:codes:)` functions to construct 
/// ErrorSets, the `|` and `|=` operators to combine error sets, and the `~=` 
/// operator (and thus `switch` statements) to test errors against error sets.
public struct ErrorSet {
    private var domainsAndCodes: [String: [Int: Void]] = [:]
    
    private init(_ input: [String: [Int]]) {
        for (key, values) in input {
            domainsAndCodes[key] = values.reduce([:] as [Int: Void]) { (var dict, code) in
                dict[code] = ()
                return dict
            }
        }
    }
}

/// The `|=` operator can be used to merge the errors matched by the ErrorSet on 
/// the right side into the ErrorSet on the left side.
public func |= (inout lhs: ErrorSet, rhs: ErrorSet) {
    for (domain, rhsCodeDictionary) in rhs.domainsAndCodes {
        let lhsCodeDictionary = lhs.domainsAndCodes[domain] ?? [:]
        
        lhs.domainsAndCodes[domain] = rhsCodeDictionary.keys.reduce(lhsCodeDictionary) { (var dict, code) in
            dict[code] = ()
            return dict
        }
    }
}

/// The `|` operator can be used to combine the errors matched by two ErrorSets 
/// into a third ErrorSet.
public func | (var lhs: ErrorSet, rhs: ErrorSet) -> ErrorSet {
    lhs |= rhs
    return lhs
}

/// The `~=` operator matches an NSError against an ErrorSet. If the NSError's 
/// domain and code are present in the ErrorSet, it returns true; otherwise it 
/// returns false.
public func ~= (lhs: ErrorSet, rhs: NSError) -> Bool {
    return lhs.domainsAndCodes[rhs.domain]?[rhs.code] != nil
}

/// Constructor for an ErrorSet matching a single error domain and code.
public func error(domain domain: String, code: Int) -> ErrorSet {
    return ErrorSet([domain: [code]])
}

/// Constructor for an ErrorSet matching several codes in a single domain.
public func errors(domain domain: String, codes: [Int]) -> ErrorSet {
    return ErrorSet([domain: codes])
}

/// Constructor for an ErrorSet matching several codes in a single domain.
/// This variant takes a variadic list of error codes; you may instead pass an 
/// array of error codes.
public func errors(domain domain: String, codes: Int...) -> ErrorSet {
    return errors(domain: domain, codes: codes)
}
