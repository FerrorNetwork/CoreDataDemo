//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Данил on 17.11.2022.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController{
    
    private let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let cellId = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        view.backgroundColor = .white
        setupNaviagtionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    @objc private func addNewTask() {
//        let newTaskViewController = NewTaskViewController()
//        newTaskViewController.modalPresentationStyle = .fullScreen
//        present(newTaskViewController, animated: true)
        showAlert(withTitle: "New Task", andMessage: "Вы хотите добавить новую задачу?")
        
    }
    
    @objc private func deleteTask() {
        
    }

    private func setupNaviagtionBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.configureWithOpaqueBackground()
        navBarApperance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarApperance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarApperance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 191/255,
            alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navBarApperance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarApperance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
           tasks = try contex.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error {
            print(error)
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    
    private func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: contex) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: contex) as? Task else { return }
        
        task.name = taskName
        tasks.append(task)
        
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if contex.hasChanges {
            do {
                try contex.save()
            } catch let error {
                print(error)
            }
        }
        dismiss(animated: true)
    }

    
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let task = tasks[indexPath.row]
        
     
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(
            style: .destructive,
            title: "Удалить") { [self] _, _, completion in
                let itemToDelete = self.tasks[indexPath.row]
                self.contex.delete(itemToDelete as NSManagedObject)
                do {
                    try self.contex.save()
                    self.tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                } catch let error {
                    print(error)
                }
            }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            .none
        }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            false
        }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let currentTask = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(currentTask, at: destinationIndexPath.row)
    }
}
