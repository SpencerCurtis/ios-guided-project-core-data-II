//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Spencer Curtis on 5/29/19.
//  Copyright © 2019 Andrew R Madsen. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {
    
    let name: String
    let notes: String?
    let priority: String
    let identifier: String
}
