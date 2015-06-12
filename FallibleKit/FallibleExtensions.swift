//
//  FallibleExtensions.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/3/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

import Foundation
import CoreData

public extension NSURL {
    func readData() -> Fallible<NSData> {
        return Fallible(catches: try NSData(contentsOfURL: self, options: []))
    }
    
    func writeData(data: NSData, options: NSDataWritingOptions) -> Fallible<Void> {
        return Fallible(catches: try data.writeToURL(self, options: options))
    }
    
    func writeData(data: NSData) -> Fallible<Void> {
        return writeData(data, options: .DataWritingAtomic)
    }
}

public extension NSFileCoordinator {
    func coordinateReadingItemAtURL<T>(url: NSURL, options: NSFileCoordinatorReadingOptions, byAccessor reader: (NSURL!) -> T) -> Fallible<T> {
        var error: NSError?
        var value: T?
        
        self.coordinateReadingItemAtURL(url, options: options, error: &error) { (url) -> Void in
            value = reader(url)
        }
        return value.map { Fallible(succeeded: $0) } ?? Fallible(failed: error!)
    }
    
    func coordinateWritingItemAtURL<T>(url: NSURL, options: NSFileCoordinatorWritingOptions, byAccessor writer: (NSURL!) -> T) -> Fallible<T> {
        var error: NSError?
        var value: T?
        
        self.coordinateWritingItemAtURL(url, options: options, error: &error) { (url) -> Void in
            value = writer(url)
        }
        return value.map { Fallible(succeeded: $0) } ?? Fallible(failed: error!)
    }
}
