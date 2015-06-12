//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to README.playground.
//

import Foundation
import XCPlayground

public let userDataURL = NSURL(fileURLWithPath: XCPSharedDataDirectoryPath).URLByAppendingPathComponent("userData").URLByAppendingPathExtension("plist")
public let emptyDataURL = NSBundle.mainBundle().URLForResource("default", withExtension: "plist")!

public struct UserData {
    public var notes: [String]
    
    public init(notes: [String]) {
        self.notes = notes
    }
}

public class MockViewController {
    public var userData: UserData? = nil
    
    public func presentError(error: ErrorType) {
        print(error)
    }
}
public var rootViewController = MockViewController()

