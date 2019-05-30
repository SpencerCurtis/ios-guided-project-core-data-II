//
//  TaskController.swift
//  Tasks
//
//  Created by Andrew R Madsen on 8/11/18.
//  Copyright © 2018 Andrew R Madsen. All rights reserved.
//

// Go through this file and figure out where we want to use a background context or the main context. (Could be multiple places)

import Foundation
import CoreData

class TaskController {
    
    let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!
    
    func put(task: Task, completion: @escaping (Error?) -> Void) {
        
        // The new UUID would be for a task created before this new migration with identifiers
        let identifier = task.identifier ?? UUID()
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        // Task -> TaskRepresentation -> JSON
        
        do {
            guard let taskRepresentation = task.taskRepresentation else {
                completion(NSError())
                return
            }
            
            request.httpBody = try JSONEncoder().encode(taskRepresentation)
            
        } catch {
            NSLog("Error encoding TaskRepresentation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting TaskRepresentation to Firebase: \(error)")
                completion(error)
                return
            }
            
            CoreDataStack.shared.mainContext.performAndWait {
                task.identifier = identifier
            }
            
            
            // Which context do we use?
            try? CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            
            completion(nil)
            }.resume()
    }
    
    func fetchTasksFromServer(completion: @escaping (Error?) -> Void) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching tasks from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            // JSON -> TaskRepresentation -> Task
            
            do {
                
                let taskRepresentations = try JSONDecoder().decode([String: TaskRepresentation].self, from: data)
                let taskRepArray = Array(taskRepresentations.values)
                
                try self.updateTasks(with: taskRepArray)
                
                completion(nil)
                
            } catch {
                NSLog("Error decoding TaskRepresentations and adding them to persistent store: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    func updateTasks(with taskRepresentations: [TaskRepresentation]) throws {
        
        // Does this task that I just fetched already exist in Core Data?
        // If it does, is it different?
        // If it doesn't, then I need to save it into Core Data
        
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        
        backgroundContext.performAndWait {
            
            for taskRep in taskRepresentations {
                
                guard let identifier = UUID(uuidString: taskRep.identifier) else { continue }
                
                if let task = getTaskFromCoreData(forUUID: identifier, context: backgroundContext) {
                    
                    // It already exists in Core Data
                    task.name = taskRep.name
                    task.notes = taskRep.notes
                    task.priority = taskRep.priority
                    
                } else {
                    let _ = Task(taskRepresentation: taskRep, context: backgroundContext)
                }
            }
        }
        
        try CoreDataStack.shared.save(context: backgroundContext)
    }
    
    // We can get a task from ANY context we want, and do it (thread) safely
    func getTaskFromCoreData(forUUID uuid: UUID, context: NSManagedObjectContext) -> Task? {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Check the name of an attribute against some value
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var result: Task? = nil
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with UUID \(uuid): \(error)")
            }
        }
        
        return result
    }
    
    
    func saveToPersistentStore() throws {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }
}
