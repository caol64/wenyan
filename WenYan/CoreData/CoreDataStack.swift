//
//  CoreDataStack.swift
//  WenYan
//
//  Created by Lei Cao on 2024/10/24.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "WenYan")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private init() { }
    
    // Add a convenience method to commit changes to the store.
    func save() throws {
        // Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        // Attempt to save changes.
        try persistentContainer.viewContext.save()
    }
    
    func delete(item: CustomTheme) throws {
        persistentContainer.viewContext.delete(item)
        try save()
    }
}
