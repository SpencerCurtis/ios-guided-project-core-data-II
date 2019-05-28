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
    convenience init(name: String, notes: String? = nil, priority: TaskPriority, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
    }
}
