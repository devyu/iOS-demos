//
//  CoreDataStack.swift
//  Todo
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 JY. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
    
  @IBOutlet weak var tableView: UITableView!
  var currentDog: Dog!
  var managedContext: NSManagedObjectContext!
  private let entityNameOfDog = "Dog"
  private let entityNameOfWalk = "Walk"
  
  
  lazy var dateFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let dogEntity = NSEntityDescription.entity(forEntityName: entityNameOfDog, in: managedContext)
    
    let dogName = "Fido"
    let dogFetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityNameOfDog)
    dogFetch.predicate = NSPredicate(format: "name == %@", dogName)
    
    // The purpose of this pattern is to manipulate an object stored in Core Data without running the risk of adding a duplicate in the process.
    do {
      let results = try managedContext.fetch(dogFetch) as! [Dog]
      if results.count > 0 {
        currentDog = results.first
      } else {
        // First launch, insert a new dog
        currentDog = Dog(entity: dogEntity!, insertInto: managedContext)
        currentDog.name = dogName
        try managedContext.save()
      }
    } catch {
      print("Error: \(error)" + "description \(error.localizedDescription)")
    }
  }

  
  // MARK: - Actions
  @IBAction func add(_ sender: AnyObject) {
      
    //Insert a new Walk entity into Core Data
    let walkEntity = NSEntityDescription.entity(forEntityName: entityNameOfWalk, in: managedContext)
    let walk = Walk(entity: walkEntity!, insertInto: managedContext)
    walk.date = Date() as NSDate?
    
    //Insert the new Walk into the Dog's walks set
    let walks = currentDog.walks?.mutableCopy() as? NSMutableOrderedSet
    walks?.add(walk)
    
    currentDog.walks = walks?.copy() as? NSOrderedSet
    
    //Save the managed object context
    do {
      try managedContext.save()
    } catch {
      print("Could not save: \(error)")
    }
    
    tableView.reloadData()
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentDog.walks!.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    let walk = currentDog.walks![indexPath.row] as! Walk
    cell.textLabel?.text = dateFormatter.string(from: walk.date as! Date)
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let walkToRemove = currentDog.walks![indexPath.row] as! Walk
      managedContext.delete(walkToRemove)
      do {
        try managedContext.save()
      } catch {
        print("Could not save: \(error.localizedDescription)")
      }
    }
    
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}

