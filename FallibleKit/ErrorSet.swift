//
//  ErrorSet.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/15/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

private extension ErrorType {
    private var domainAndCode: (String, Int) {
        let nsError = self as NSError
        return (nsError.domain, nsError.code)
    }
}

/// An ErrorSet represents a particular set of NSError domains and codes within 
/// those domains. ErrorSet itself has no public API, but you can use the 
/// `error(domain:code:)` and `errors(domain:codes:)` functions to construct 
/// ErrorSets, the `|` and `|=` operators to combine error sets, and the `~=` 
/// operator (and thus `switch` statements) to test errors against error sets.
public struct ErrorSet: SetAlgebraType {
    private var domainsAndCodes: [String: Set<Int>] = [:]
    
    private subscript(domain: String, code: Int) -> Bool {
        get { return domainsAndCodes[domain]?.contains(code) ?? false }
        set {
            if newValue {
                if domainsAndCodes[domain] == nil {
                    domainsAndCodes[domain] = [code]
                }
                else {
                    domainsAndCodes[domain]!.insert(code)
                }
            }
            else {
                domainsAndCodes[domain]?.remove(code)
            }
        }
    }
    
    /// Creates an empty set.
    ///
    /// - Equivalent to `[] as Self`
    public init() {}
    
    /// Returns `true` if `self` contains `member`.
    ///
    /// - Equivalent to `self.intersect([member]) == [member]`
    public func contains(member: ErrorType) -> Bool {
        return self[member.domainAndCode]
    }
    
    /// Returns the set of elements contained in `self`, in `other`, or in
    /// both `self` and `other`.
    public func union(var other: ErrorSet) -> ErrorSet {
        other.unionInPlace(self)
        return other
    }
    
    /// Returns the set of elements contained in both `self` and `other`.
    public func intersect(var other: ErrorSet) -> ErrorSet {
        other.intersectInPlace(self)
        return other
    }
    
    /// Returns the set of elements contained in `self` or in `other`,
    /// but not in both `self` and `other`.
    public func exclusiveOr(other: ErrorSet) -> ErrorSet {
        var both = union(other)
        for (domain, codes) in both.domainsAndCodes {
            for code in codes {
                if self[domain, code] && other[domain, code] {
                    both[domain, code] = false
                }
            }
        }
        return other
    }
    
    /// If `member` is not already contained in `self`, inserts it.
    ///
    /// - Equivalent to `self.unionInPlace([member])`
    /// - Postcondition: `self.contains(member)`
    public mutating func insert(member: ErrorType) {
        self[member.domainAndCode] = true
    }
    
    /// If `member` is contained in `self`, removes and returns it.
    /// Otherwise, removes all elements subsumed by `member` and returns
    /// `nil`.
    ///
    /// - Postcondition: `self.intersect([member]).isEmpty`
    public mutating func remove(member: ErrorType) -> ErrorType? {
        guard self[member.domainAndCode] else {
            return nil
        }
        
        self[member.domainAndCode] = false
        return member
    }
    
    /// Insert all elements of `other` into `self`.
    ///
    /// - Equivalent to replacing `self` with `self.union(other)`.
    /// - Postcondition: `self.isSupersetOf(other)`
    public mutating func unionInPlace(other: ErrorSet) {
        for (domain, otherCodes) in other.domainsAndCodes {
            var selfCodes = domainsAndCodes[domain] ?? []
            selfCodes.unionInPlace(otherCodes)
            domainsAndCodes[domain] = selfCodes
        }
    }
    
    /// Removes all elements of `self` that are not also present in
    /// `other`.
    ///
    /// - Equivalent to replacing `self` with `self.intersect(other)`
    /// - Postcondition: `self.isSubsetOf(other)`
    public mutating func intersectInPlace(other: ErrorSet) {
        for domain in domainsAndCodes.keys {
            if let otherCodes = other.domainsAndCodes[domain] {
                domainsAndCodes[domain]!.intersectInPlace(otherCodes)
            }
            else {
                domainsAndCodes[domain] = nil
            }
        }
    }
    
    /// Replaces `self` with a set containing all elements contained in
    /// either `self` or `other`, but not both.
    ///
    /// - Equivalent to replacing `self` with `self.exclusiveOr(other)`
    public mutating func exclusiveOrInPlace(other: ErrorSet) {
        // No clue how to do this in-place
        self = exclusiveOr(other)
    }
    
    /// Returns true iff `self.contains(e)` is `false` for all `e`.
    public var isEmpty: Bool { 
        return domainsAndCodes.indexOf { (_, codes) in !codes.isEmpty } == nil
    }
    
    /// Returns `true` iff `a` subsumes `b`.
    ///
    /// - Equivalent to `([a] as Self).isSupersetOf([b])`
    public static func element(a: ErrorType, subsumes b: ErrorType) -> Bool {
        if case let ((d1, c1), (d2, c2)) = (a.domainAndCode, b.domainAndCode) where d1 == d2 && c1 == c2 {
            return true
        }
        else {
            return false
        }
    }
}

public func == (lhs: ErrorSet, rhs: ErrorSet) -> Bool {
    return lhs.exclusiveOr(rhs).isEmpty
}

/// The `|=` operator can be used to merge the errors matched by the ErrorSet on 
/// the right side into the ErrorSet on the left side.
public func |= (inout lhs: ErrorSet, rhs: ErrorSet) {
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
public func ~= (lhs: ErrorSet, rhs: ErrorType) -> Bool {
    return lhs.contains(rhs)
}

/// Constructor for an ErrorSet matching a specific Swift ErrorType.
public func error(error: ErrorType) -> ErrorSet {
    var all = ErrorSet()
    all.insert(error)
    return all
}

/// Constructor for an ErrorSet matching one of many Swift ErrorTypes. This variant
/// takes an array, and can thus match a set of types determined at runtime.
public func errors(errors: [ErrorType]) -> ErrorSet {
    var all: ErrorSet = []
    errors.map(all.insert)
    return all
}

// Constructor for an ErrorSet matching one of many Swift ErrorTypes. This variant
// is variadic, and thus has a cleaner syntax.
public func errors(errors e: ErrorType...) -> ErrorSet {
    return errors(e)
}

/// Constructor for an ErrorSet matching specific error domains and codes.
public func errors(domain domain: String, codes: Set<Int>) -> ErrorSet {
    var all = ErrorSet()
    all.domainsAndCodes = [domain: codes]
    return all
}
