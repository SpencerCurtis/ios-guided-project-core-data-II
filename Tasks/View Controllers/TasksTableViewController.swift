//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Andrew R Madsen on 8/11/18.
//  Copyright © 2018 Andrew R Madsen. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            let moc = CoreDataStack.shared.mainContext
            moc.delete(task)
            do {
                try moc.save()
                tableView.reloadData()
            } catch {
                moc.reset()
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        // What do we want to do to the table view based on the change type?
        
        switch type {
        case .insert:
            tableView.insertRows(at: <#T##[IndexPath]#>, with: <#T##UITableViewRowAnimation#>)
        case .delete:
            
        case .move:
            
        case .update:
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetail" {
            let detailVC = segue.destination as! TaskDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.task = tasks[indexPath.row]
            }
        }
    }
    
    // MARK: Properties
    
    // NOTE! This is not a good, efficient way to do this, as the fetch request
    // will be executed every time the tasks property is accessed. We will
    // learn a better way to do this later.
    
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        // The key corresponds to the name of an entity's attribute
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "priority", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
}
