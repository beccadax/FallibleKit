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
