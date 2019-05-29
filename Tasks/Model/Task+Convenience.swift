//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Andrew R Madsen on 8/11/18.
//  Copyright © 2018 Andrew R Madsen. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String {
    case low
    case normal
    case high
    case critical

    static var allPriorities: [TaskPriority] {
        return [.low, .normal, .high, .critical]
    }
    
//    static func priority(for index: Int) -> TaskPriority {
//        switch index {
//        case 0:
//            return .low
//
//        default:
//            <#code#>
//        }
//    }
}

extension Task {
    
    convenience init(name: String, notes: String? = nil, priority: TaskPriority, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
        self.identifier = identifier
    }
    
    // Used for converting a TaskRepresentation from Firebase to a Task object
    
    convenience init?(taskRepresentation: TaskRepresentation,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let priority = TaskPriority(rawValue: taskRepresentation.priority),
            let identifier = UUID(uuidString: taskRepresentation.identifier) else {
                // We don't have enough information to create a Task object, return nil instead
                return nil
        }
        
        self.init(name: taskRepresentation.name, notes: taskRepresentation.notes, priority: priority, identifier: identifier, context: context)
    }
    
    // Used for sending the Task object to Firebase
    
    var taskRepresentation: TaskRepresentation? {
        
        guard let name = name,
            let priority = priority else { return nil }
        
        return TaskRepresentation(name: name, notes: notes, priority: priority, identifier: identifier?.uuidString ?? "")
    }
}


























