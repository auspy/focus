//
//  Persistence.swift
//  focusmode
//
//  Created by Kshetez Vinayak on 13/12/24.
//

import CoreData

struct PersistenceController {
    // MARK: - Shared Instance
    static let shared = PersistenceController()
    
    // MARK: - Storage
    let container: NSPersistentContainer
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "focusmode")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        setupDefaultSettings()
    }
    
    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data for previews if needed
        return controller
    }()
    
    // MARK: - Setup
    private func setupDefaultSettings() {
        let context = container.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Enable automatic merging of changes
        context.automaticallyMergesChangesFromParent = true
        
        // Set up some default fetch batch size
        context.shouldDeleteInaccessibleFaults = true
    }
    
    // MARK: - Save Helper
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
