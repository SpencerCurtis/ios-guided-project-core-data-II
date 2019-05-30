//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Andrew R Madsen on 8/11/18.
//  Copyright © 2018 Andrew R Madsen. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        let notes = notesTextView.text
        
        let priorityIndex = priorityControl.selectedSegmentIndex // 0 - 3
        
        let priority = TaskPriority.allPriorities[priorityIndex]
        
        CoreDataStack.shared.mainContext.performAndWait {
            
            if let task = task {
                // Editing existing task
                task.name = name
                task.notes = notes
                task.priority = priority.rawValue
                
                taskController?.put(task: task, completion: { (_) in
                    // In a real app, handle the error with an alert or something similar to show the user that the task was not saved to Firebase
                })
            } else {
                let task = Task(name: name, notes: notes, priority: priority)
                
                taskController?.put(task: task, completion: { (_) in
                    // Same as above
                })
            }
            
            do {
                try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard let task = self.task,
            isViewLoaded else { return }
        
        var name: String?
        var notes: String?
        
        task.managedObjectContext?.performAndWait {
            name = task.name
            notes = task.notes
        }
        
        title = name ?? "Create Task"
        nameTextField.text = name
        notesTextView.text = notes
        
        if let taskPriority = task.priority,
            let priority = TaskPriority(rawValue: taskPriority) {
            
            priorityControl.selectedSegmentIndex = TaskPriority.allPriorities.firstIndex(of: priority) ?? 0
        }
        
    }
    
    // MARK: Properties
    
    var taskController: TaskController?
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
}
