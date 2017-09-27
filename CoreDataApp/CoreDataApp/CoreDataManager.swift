//
//  CoreDataManager.swift
//  CoreDataApp
//
//  Created by S.t on 2017/9/26.
//  Copyright © 2017年 S.t. All rights reserved.
//

import CoreData
import Foundation

public class CoreDataManager{
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // Managed Object Model : Lazy initialization
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        
        // Fetch model url
        guard let modelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            return nil
        }
        
        // Initialize Managed object model
        let managedObjectModel = NSManagedObjectModel.init(contentsOf: modelUrl)
        
        return managedObjectModel
    }()
    
    // Build persistent store url
    private var persistentStoreUrl: URL{
        // Helpers
        let storeName = "\(self.modelName).sqlite"
        let fileManager = FileManager.default
        
        let documentsDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return documentsDirectoryUrl.appendingPathComponent(storeName)
    }
    
    // Persistent Store Coordinator : Lazy initialization
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
        // Ensure the managed object model exists.
        guard let managedObjectModel = self.managedObjectModel else{
            return nil
        }
        // Get the url
        let persistentStoreUrl = self.persistentStoreUrl
        
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjectModel)
        
        do{
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption : true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType , configurationName: nil, at: persistentStoreUrl , options: options)
        }catch{
            let addPersistentStoreError = error as NSError
            
            print("Unable to add persistent store.")
            
            print("\(addPersistentStoreError.localizedDescription)")
            
        }
        return persistentStoreCoordinator
        
    }()
    
    // Initialize managed object context
    public private(set) lazy var managedObjectContex: NSManagedObjectContext = {
        // Initialize managed object context
        let managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure managed object context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    // Add object to managed object context
    func addEmployer() -> Bool {
        let employer = NSEntityDescription.insertNewObject(forEntityName: "Employer", into: self.managedObjectContex) as! EmployerMO
        
        employer.setValue("Sitong", forKey: "firstName")
        employer.setValue("Chen", forKey: "lastName")
        
        
        
        do{
            try self.managedObjectContex.save()
        }catch{
            fatalError("Failure to save context: \(error)")
        }
        
        return true
    }
    
    // Fetch employers
    func fetchEmployers() -> Int{
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Employer")
        request.predicate = NSPredicate.init(format: "lastName== %@", argumentArray: ["Chen"])
        
        do{
            let num = try self.managedObjectContex.count(for: request)
            let list = try self.managedObjectContex.fetch(request) as! [EmployerMO]
            print(list)
            for element in list{
                print("\(element.lastName!)  \( element.firstName!)")
            }
//            for element in list{
//                self.managedObjectContex.delete(element)
//            }
//            try self.managedObjectContex.save()
            return num
        }catch{
            fatalError("Failed to fetch employers.")
        }
        
        return 0
    }
    
}
