//
//  FallibleExtensions.swift
//  WishList
//
//  Created by Brent Royal-Gordon on 9/3/14.
//  Copyright (c) 2014 Architechies. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    func save() -> Fallible<Void> {
        return toFallible { (inout error: NSError?) in self.save(&error) }
    }
    
    func existingObjectWithID(objectID: NSManagedObjectID) -> Fallible<NSManagedObject> {
        return toFallible { (inout error: NSError?) in
            self.existingObjectWithID(objectID, error: &error)
        }
    }
}

public extension NSPersistentStoreCoordinator {
    func addPersistentStoreWithType(storeType: String, configuration: String?, URL storeURL: NSURL!, options: [NSObject : AnyObject]?) -> Fallible<NSPersistentStore> {
        return toFallible { (inout error: NSError?) in
            self.addPersistentStoreWithType(storeType, configuration: configuration, URL: storeURL, options: options, error: &error)
        }
    }
}

public extension NSURL {
    func readData() -> Fallible<NSData> {
        return toFallible { (inout error: NSError?) in
            NSData(contentsOfURL: self, options: nil, error: &error)
        }
    }
    
    func writeData(data: NSData, options: NSDataWritingOptions) -> Fallible<Void> {
        return toFallible { (inout error: NSError?) in
            data.writeToURL(self, options: options, error: &error)
        }
    }
    
    func writeData(data: NSData) -> Fallible<Void> {
        return writeData(data, options: .DataWritingAtomic)
    }
}

public extension NSPropertyListSerialization {
    class func propertyListWithData(data: NSData, options: NSPropertyListReadOptions, format: UnsafeMutablePointer<NSPropertyListFormat> = nil) -> Fallible<AnyObject> {
        return toFallible { (inout error: NSError?) in
            self.propertyListWithData(data, options: options, format: format, error: &error)
        }
    }
    
    class func propertyListWithData(data: NSData) -> Fallible<AnyObject> {
        return propertyListWithData(data, options: 0)
    }
    
    class func dataWithPropertyList(plist: AnyObject, format: NSPropertyListFormat, options: NSPropertyListWriteOptions = 0) -> Fallible<NSData> {
        return toFallible { (inout error: NSError?) in
            self.dataWithPropertyList(plist, format: format, options: options, error: &error)
        }
    }
    
    class func dataWithPropertyList(plist: AnyObject) -> Fallible<NSData> {
        return dataWithPropertyList(plist, format: .XMLFormat_v1_0)
    }
}

public extension NSFileManager {
    func removeItemAtURL(URL: NSURL) -> Fallible<Void> {
        return toFallible { (inout error: NSError?) in
            self.removeItemAtURL(URL, error: &error)
        }
    }
}

public extension NSFileCoordinator {
    func coordinateReadingItemAtURL<T>(url: NSURL, options: NSFileCoordinatorReadingOptions, byAccessor reader: (NSURL!) -> T) -> Fallible<T> {
        return toFallible { (inout error: NSError?) -> T? in
            var value: T?
            self.coordinateReadingItemAtURL(url, options: options, error: &error) { (url) -> Void in
                value = reader(url)
            }
            return value
        }
    }
    
    func coordinateWritingItemAtURL<T>(url: NSURL, options: NSFileCoordinatorWritingOptions, byAccessor writer: (NSURL!) -> T) -> Fallible<T> {
        return toFallible { (inout error: NSError?) -> T? in
            var value: T?
            self.coordinateWritingItemAtURL(url, options: options, error: &error) { (url) -> Void in
                value = writer(url)
            }
            return value
        }
    }
}
