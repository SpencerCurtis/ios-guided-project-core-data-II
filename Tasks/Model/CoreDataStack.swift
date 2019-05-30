//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Andrew R Madsen on 8/11/18.
//  Copyright © 2018 Andrew R Madsen. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    /// A generic function to save any context we want (main or background)
    
    func save(context: NSManagedObjectContext) throws {
        
        // A placeholder for the potential error we could get in this function if something doesn't work.
        var error: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                NSLog("Error saving moc: \(saveError)")
                error = saveError
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext  {
        return container.viewContext
    }
}
