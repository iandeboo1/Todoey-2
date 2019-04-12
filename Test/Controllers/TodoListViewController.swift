//
//  ViewController.swift
//  Todoey
//
//  Created by Ian DeBoo on 4/10/19.
//  Copyright © 2019 Ian DeBoo. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            //this keyword allows things to happen once an optional value is set
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //this line taps into a Singleton for the AppDelegate class and allows the context (a.k.a. the temporary holding area) to be accessed from this class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        //this line creates the cell item and names it "cell", links to the protype cell with the name "ToDo..."; also make sure that the i in index path is lowercase
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        //this is called a Ternary Operator and basically takes the places of and shortens an if-else statement in certain cases
        
        return cell
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        //these two lines together remove an item from the array and the core database, respectively; THEY ALSO HAVE TO BE IN THIS ORDER
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
    
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            let newItem = Item(context: self.context)
            //this creats a new item and places it within the context
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addAction(action)
        
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    //MARK: - Model Manipulation Actions
    
    func saveItems() {
        
        do {
            try self.context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //the with is an external input so it's what the input is called when used elsewhere, while request is used here in the code block
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name CONTAINS %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
           itemArray = try context.fetch(request)
            //this actaully pulls data to the context area for reading
        } catch {
            print("Error fetching data from context, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
}
//////////////////////////////////////////////////////////////////////////////////
//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    //this allows for more functionalities for a single class and also adds a further level of code organization by butting only code related to this set of rules (search bar) in this extension section
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //this assigns fetching funcitonality to the request variable
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //this line creates a query; the format is in a language called NS predicate and there's an entire bookmarked cheat sheet if need be; the [cd] isn't necessary but removes case sensitivity
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //this creates a sort filter that sorts the titles in ascending alphabetical order; it also adds the filter to the fetch request; notice that it is formatted as an array becuase multiple different filters can all be added
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
            
        } else {
            loadItems()
    
            DispatchQueue.main.async {
                //this runs this function in the fireground; all UI updates should be run this way
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
