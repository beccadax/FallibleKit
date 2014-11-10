//
//  FallibleChaining.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/14/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

import Foundation

infix operator => { associativity left precedence 80 }

/// The function chaining operator is used to link several operations together into a 
/// pipeline. You begin the pipeline with a value, then use the `=>` operator 
/// one or more times to pass it through a series of transformations. Each 
/// transformation is a function, and each function in the chain must accept a 
/// single parameter of the type returned by the previous function. The end of the 
/// chain returns the value after all the transformations are applied.
/// 
/// Although this operator can be used with any value and any function, it is 
/// specifically intended to be used with Fallible values. See `then`, 
/// `mapSuccess`, `recover`, and `mapFailure` for examples of operations that can 
/// be used with function chaining and Fallible values.
public func => <T, U> (input: T, transform: T -> U) -> U {
    return transform(input)
}

/// The function chaining operator is used to link several operations together into a 
/// pipeline. You begin the pipeline with a value, then use the `=>` operator 
/// one or more times to pass it through a series of transformations.
/// 
/// This variant is used to build a function chain when you don't yet have the 
/// value you're going to transform. One reason you might do this is to build up a 
/// completion function for an asynchronous operation.
/// 
/// Although this operator can be used with any value and any function, it is 
/// specifically intended to be used with Fallible values. See `then`, 
/// `mapSuccess`, `recover`, and `mapFailure` for examples of operations that can 
/// be used with function chaining and Fallible values.
public func => <T, U, V> (first: T -> U, second: U -> V)(input: T) -> V {
    return input => first => second
}

/// When used with the function chaining operator (`=>`), chains two Fallible 
/// operations together, ensuring that the second runs only if the first succeeded. 
/// It can be thought of as similar to `Optional.map`.
/// 
/// If the previous Fallible operation succeeded, `then` extracts the value and 
/// passes it to the `operation` function. It then returns the result of 
/// `operation`, which should itself be Fallible, though perhaps with a 
/// different ResultType.
/// 
/// If the current Fallible operation failed, `then` does not run `operation`, 
/// but instead propagates the current operation's error into a new Fallible 
/// result.
public func then<T, U>(operation: T -> Fallible<U>)(input: Fallible<T>) -> Fallible<U> {
    switch input {
    case .Success(let reference):
        return operation(reference.value)
    case .Failure(let error):
        return Fallible.Failure (error)
    }
}

/// When used with the function chaining operator (`=>`), transforms the value of a 
/// successful Fallible operation, possibly changing its type in the process. Use 
/// `mapSuccess` instead of `then` when the operation you want to perform is 
/// not itself Fallible.
public func mapSuccess<T, U>(transform: T -> U) -> Fallible<T> -> Fallible<U> {
    return then { Fallible(succeeded: transform($0)) }
}

/// When used with the function chaining operator (`=>`), chains two Fallible 
/// operations together, ensuring that the second runs only if the first failed. This 
/// allows you to potentially correct a failure and return to the main successful 
/// flow of control through your code.
/// 
/// If the current Fallible operation failed, `recover` extracts the error and 
/// passes it to the `recovery` function. It then returns the result of 
/// `recovery`, which should itself be Fallible.
/// 
/// If the current Fallible operation succeeded, `recover` does not run 
/// `recovery`, instead returning the current result unchanged.
/// 
/// To recover selectively from only certain errors, see `recover(from:recovery:)
public func recover<T>(recovery: NSError -> Fallible<T>)(input: Fallible<T>) -> Fallible<T> {
    switch input {
    case .Success:
        return input
    case .Failure(let error):
        return recovery(error)
    }
}

/// When used with the function chaining operator (`=>`), chains two Fallible 
/// operations together, ensuring that the second runs only if the first failed. This 
/// allows you to potentially correct a failure and return to the main successful 
/// flow of control through your code.
/// 
/// If the current Fallible operation failed, `recover` extracts the error and 
/// passes it to the `recovery` function. It then returns the result of 
/// `recovery`, which should itself be Fallible.
/// 
/// If the current Fallible operation succeeded, `recover` does not run 
/// `recovery`, instead returning the current result unchanged.
/// 
/// The `recover(from:recovery:)` variant only runs the `recovery` function if the 
/// error matches the particular error set specified in the parameters. All other 
/// failures pass through `recover(from:recovery:)` unchanged. To try to recover 
/// from all failures, see `recover(_:)`. To construct error sets, see 
/// `error(domain:code:)`, `errors(domain:codes:)`, and the error set combining 
/// operator, `|`.
public func recover<T>(from errorSet: ErrorSet, recovery: NSError -> Fallible<T>) -> Fallible<T> -> Fallible<T> {
    return recover { error in
        if errorSet ~= error {
            return recovery(error)
        }
        else {
            return Fallible.Failure(error)
        }
    }
}

/// When used with the function chaining operator (`=>`), transforms the error of a 
/// failed Fallible operation. This is often used to wrap an NSError in a more 
/// general, domain-specific NSError, or to add additional domain-specific 
/// information to the NSError. Use `mapFailure` instead of `recover` when the 
/// operation does not try to fix the error, but merely substitutes a different error 
/// for the original.
/// 
/// To convert only certain errors, see `mapFailure(from:transform:)`.
public func mapFailure<T>(transform: NSError -> NSError) -> Fallible<T> -> Fallible<T> {
    return recover { error in Fallible.Failure (transform(error)) }
}

/// When used with the Fallible chaining operator (`=>`), transforms the error of a 
/// failed Fallible operation. This is often used to wrap an NSError in a more 
/// general, domain-specific NSError, or to add additional domain-specific 
/// information to the NSError. Use `mapFailure` instead of `recover` when the 
/// operation does not try to fix the error, but merely substitutes a different error 
/// for the original.
/// 
/// The `mapFailure(from:transform:)` variant only runs the `transform` 
/// function if the error matches the particular error set specified in the 
/// parameters. All other failures pass through `mapFailure(from:transform:)` 
/// unchanged. To transform all failures, see `mapFailure(transform:)`. To 
/// construct error sets, see `error(domain:code:)`, `errors(domain:codes:)`, and 
/// the error set combining operator, `|`.
public func mapFailure<T>(from errorSet: ErrorSet, #transform: NSError -> NSError) -> Fallible<T> -> Fallible<T> {
    return recover(from: errorSet) { error in Fallible.Failure (transform(error)) }
}
