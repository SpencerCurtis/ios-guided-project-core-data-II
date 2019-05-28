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
        
        if let task = task {
            // Editing existing task
            task.name = name
            task.notes = notes
            task.priority = priority.rawValue
        } else {
            let _ = Task(name: name, notes: notes, priority: priority)
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard let task = self.task,
            isViewLoaded else { return }
        
        title = task.name ?? "Create Task"
        nameTextField.text = task.name
        notesTextView.text = task.notes
        
        if let taskPriority = task.priority,
            let priority = TaskPriority(rawValue: taskPriority) {
            
            priorityControl.selectedSegmentIndex = TaskPriority.allPriorities.firstIndex(of: priority) ?? 0
        }
        
    }
    
    // MARK: Properties
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
}
