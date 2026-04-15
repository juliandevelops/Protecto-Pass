//
//  Persistence.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import CoreData

/// The Persistence Controller to connect the App
/// to the Core Data Manager
internal struct PersistenceController {
    
    /// The Persistence Controller to use everywhere in this App
    internal static let shared : PersistenceController = PersistenceController()
    
    /// The Preview Persistence Controller to only use in Previews
    internal static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let db : CD_Database = CD_Database(context: viewContext)
            db.name = DataConverter.stringToData("Database \(i)")
            db.details = DataConverter.stringToData("This is the Database Number \(i)")
            db.iconName = DataConverter.stringToData("externaldrive")
            let header : CD_DB_Header = CD_DB_Header(context: viewContext)
            header.encryption = Cryptography.Encryption.AES256.rawValue
            header.storageType = Storage.StorageType.CoreData.rawValue
            header.salt = try! PasswordGenerator.generateSalt()
            header.keyParams = CD_DB_HeaderKeyParameters(context: viewContext)
            db.header = header
            db.createdDate = DataConverter.dateToData(Date.now)
            db.lastEditedDate = DataConverter.dateToData(Date.now)
        }
        do {
            try viewContext.save()
        } catch {
            // TODO: replace with error handling
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    

    

    /// The Container actually containing all the Stores, the ViewContext and other relevant things
    internal let container: NSPersistentCloudKitContainer
    
    internal init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Protecto_Pass")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // NSPersistentStoreFileProtectionKey is not available
        // on macOS, so this is only compiled and added, if the OS
        // is not macOS
#if !os(macOS)
        // Core Data Encryption Idea from: https://cocoacasts.com/is-core-data-encrypted
        container.persistentStoreDescriptions.first!.setOption(
            FileProtectionType.complete as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
#endif
        // Automatically merge Changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        // Idea for this merge policy: https://www.reddit.com/r/iOSProgramming/comments/egki07/which_merge_policy_should_i_use_for_cloudkitcore/
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.shouldDeleteInaccessibleFaults = true // TODO: check (and next line)
        container.viewContext.retainsRegisteredObjects = true
    }
}
