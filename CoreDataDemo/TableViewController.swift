//
//  TableViewController.swift
//  CoreDataDemo
//
//  Created by admin on 26.07.2022.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [MyTask] = []

    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Please, add new task", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertController.textFields?.first
            if let newTaskTitle = textField?.text{
                self.saveTask(withTitle: newTaskTitle)
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
            
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    private func saveTask(withTitle title: String){
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "MyTask", in: context) else {return}
        let taskObject = MyTask(entity: entity, insertInto: context)
        taskObject.title = title
        
        do{
            try context.save()
            self.tasks.append(contentsOf: [taskObject])
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = tasks[indexPath.row].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, _  in
            let objectToRemove = self.tasks[indexPath.row]
            let context = self.getContext()
            let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
            if let objects = try? context.fetch(fetchRequest){
                for object in objects{
                    if object == objectToRemove{
                        self.tasks.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        context.delete(object)
                        print("\(objectToRemove.title) was deleted")
                    }
                }
            }

            do {
                try context.save()
            } catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
