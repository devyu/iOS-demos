//
//  CoreDataStack.swift
//  Todo
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 JY. All rights reserved.
//


import CoreData

class CoreDataStack {
    
  let modelName = "DogWalk"
  
  public lazy var applicationDocumentsDirectory: NSURL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1] as NSURL
  }()
  
  
  // MARK: - Core Data stack
  public lazy var managedObjectContext: NSManagedObjectContext = {
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = self.psc
    return managedObjectContext
  }()
  
  
  private var psc: NSPersistentStoreCoordinator {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName)
    do {
      // configuration persistent store
      let options = [NSMigratePersistentStoresAutomaticallyOption : true]
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
    } catch {
      print("Adding persistnet store error: \(error.localizedDescription)")
    }
    return coordinator
  }
  
  
  // note: the momd directory contains the cocnpiled version of the .xcdatamodeld file
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  
  
  public func saveContext() {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        print("Save error: \(error.localizedDescription)")
        abort()
      }
    }
  }
}
