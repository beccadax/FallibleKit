/*:
FallibleKit
=======
*/
import FallibleKit
/*:
FallibleKit is an implementation of functional-style error handling for Swift. Functional-style error handling allows you to easily handle errors by chaining operations together; FallibleKit makes this readable and understandable.

This version of FallibleKit is written in Swift 2.0. [A Swift 1.2 branch is also available.](https://github.com/brentdax/FallibleKit/tree/v1.x) It only includes iOS targets, although FallibleKit should be able to run on OS X.

Fallible
------

A `Fallible<T>` value represents a value of type `T` that was created in a way that might fail. For instance, an `NSData` read from a file that might not exist would be a `Fallible<NSData>`. If the operation succeeded, the Fallible instance will contain a piece of data; if it failed, the Fallible instance will contain an NSError describing the failure.

A Fallible instance may have succeeded or it may have failed:
*/

let okay = Fallible(succeeded: "Hello world!")
let oops = Fallible<String>(failed: NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError, userInfo: nil))

/*:
If an operation does not return any useful value, but merely wants to report whether it succeeded or failed (and the error if it failed), it should have a return type of `Fallible<Void>`. The syntax for constructing a succeeded `Fallible<Void>` is a little awkward, so FallibleKit includes a `Succeeded` constant you can return instead.

A successful Fallible instance will have its value in the `value` property; a failed one will have `nil` there. Similarly, a failed Fallible instance will have its error in its `error` property; a successful Fallible instance will have `nil` there. You can also check the `succeeded` and `failed` properties for a simple boolean test.
*/

okay.succeeded
okay.value
okay.failed
okay.error

oops.succeeded
oops.value
oops.failed
oops.error

/*:
To use Fallible, simply wrap the type you would return when successful in `Fallible<>`, then use the `succeeded:` and `failed:` constructors as needed.
*/

extension UserData {
    static func fromPropertyList(plist: AnyObject) -> Fallible<UserData> {
        if let plist = plist as? NSDictionary,
            let notes = plist["notes"] as? [String] {
                // Great, the file had everything we needed
                return Fallible(succeeded: UserData(notes: notes))
        }
        else {
            // Oops, something was missing
            let error = NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [NSLocalizedDescriptionKey : "The data was not saved correctly." ])
            return Fallible(failed: error)
        }
    }
}

/*:
Fallibles and Framework APIs
---------------------

When you're writing your own APIs, you should have them return (or, for asynchronous calls, pass) `Fallible` types directly, but you have no such luxury with standard Foundation, Cocoa Touch, or Cocoa APIs. If they use Swift's standard `throws` feature, the `Fallible(catches:)` initializer can help you convert their results to Fallible instances.
*/

public func readPropertyListWithToFallible(URL: NSURL) -> Fallible<AnyObject> {
    let dataResult = Fallible(catches: try NSData(contentsOfURL: URL, options: []))
    
    if let data = dataResult.value {
        return Fallible(catches: try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil))
    }
    else {
        // Have to convert this to a Fallible<AnyObject>
        return Fallible(failed: dataResult.error!)
    }
}

/*:
FallibleKit also includes extensions which create Fallible versions of a few APIs which are, for some reason, awkward to use with FallibleKit. Additions to these extensions are always welcome.
*/

public func readPropertyList(URL: NSURL) -> Fallible<AnyObject> {
    let dataResult = URL.readData()     // Here
        
    if let data = dataResult.value {
        return Fallible(catches: try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil))
    }
    else {
        return Fallible(failed: dataResult.error!)
    }
}

/*:
Fallible Chaining
------------

It's possible to work with Fallible instances purely by using `if` and `if let` statements with the four properties described above, but Fallible gets really powerful if you use its chaining operations.

Fallible chaining treats your code as a pipeline. Each step in the chain runs in a certain condition and transforms the result of the previous step in a certain way. For instance, you might read in a piece of raw data, correct a specific error by substituting default data, transform the data into a model object, set a property on your root view controller to your new model object, and display any unhandled errors that came up during this whole process:
*/

readPropertyList(userDataURL) =>
    // This step is run only if we've encounted the specified error.
    // It runs another operation that might fail.
    recover(from: error(NSCocoaError.FileReadNoSuchFileError)) { error in
        readPropertyList(emptyDataURL) 
    } =>
    // This step is run only if we've successfully read a plist.
    // It takes the plist and performs another operation that might fail.
    then { plist in
        UserData.fromPropertyList(plist)
    } =>
    // This step is run only if the previous step ran successfully.
    // It uses the UserData instance without replacing it.
    useSuccess { userData in
        rootViewController.userData = userData
    } =>
    // This step is run only if the previous steps produced an error.
    // It uses the error without replacing it.
    useFailure { error in
        rootViewController.presentError(error)
    }

/*:
Operations supported by Fallible include:

* `then`: If previous steps succeeded, perform an additional step that might fail.
* `mapSuccess`: If previous steps succeeded, perform additional processing that cannot fail.
* `useSuccess`: If previous steps succeeded, use their value without replacing it.
* `recover`: If previous steps failed, perform an additional step that might fail, but also might succeed.
* `mapFailure`: If previous steps failed, replace the error with a different error.
* `correct` If previous steps failed, perform a corrective action that cannot fail.
* `useFailure`: If previous steps failed, use their error without replacing it.

The error-related operations all support an optional `from:` parameter which specifies particular errors you want to handle.

Copyright
-------

Copyright © 2014-15 Architechies.

This library is licensed under the MIT License:

> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author
----

Brent Royal-Gordon, <brent@architechies.com>, @brentdax on GitHub and Twitter.

*/
