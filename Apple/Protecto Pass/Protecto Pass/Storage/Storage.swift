//
//  Storage.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.03.23.
//

import CoreData
import Foundation
import UIKit

/// The Structure to use when storing
/// Databases and other Data. This Struct
/// chooses the right Storage Struct and Functionality
/// depending on the User Preferences on storing
/// Data.
internal struct Storage {
    
    /// The Enum to declare how the Database is stored.
    internal enum StorageType : String, RawRepresentable, CaseIterable, Identifiable {
        var id : Self { self }
        
        /// Storing this Database as an encrypted Core Data Instance
        case CoreData
        
        /// Storing this Database in an local encrypted binary File
        case File
    }
    
    /// Loads all the Databases from the different Storage Options
    internal static func load(with context : NSManagedObjectContext, usingFilepaths paths : [URL]) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        // Core Data
        let coreData : [EncryptedDatabase] = try CoreDataManager.load(with: context)
        result.append(contentsOf: coreData)
        // File System
//        let fileSystem : [EncryptedDatabase] = try DatabaseFileManager.load(from: paths)
//        result.append(contentsOf: fileSystem)
        result.sort(by: { $0.lastEditedDate < $1.lastEditedDate })
        return result
    }
    
    internal static func loadImages(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Image] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadImages Function")
                return try CoreDataManager.loadImages(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    internal static func loadVideos(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Video] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadVideos Function")
                return try CoreDataManager.loadVideos(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    internal static func loadDocuments(_ db : Database, ids: [UUID], context : NSManagedObjectContext?) throws -> [DB_Document] {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To load Core Data Images, a Context must be provided to the loadDocuments Function")
                return try CoreDataManager.loadDocuments(db, ids: ids, with: context!)
            case .File:
                return []
        }
    }
    
    /// Stores the passed Database to the right Storage.
    /// if you want to store something in Core Data, the connected context has to be provided.
    internal static func storeDatabase(
        _ db : EncryptedDatabase,
        context : NSManagedObjectContext?
    ) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Databases, a Context must be provided to the storeDatabase Function")
                try CoreDataManager.storeDatabase(
                    db,
                    context: context!
                )
            case .File:
                break
//                try DatabaseFileManager.storeDatabase(db)
        }
    }
    
    private static func getFolderIfExists(
        ds : DB_ME_DataStructure<
                String,
                Date,
                DB_Folder,
                DB_Entry,
                DB_LoadableResource,
                DB_CreditCard,
                DB_Note,
                DB_Passkey,
                UUID,
                DB_Tag
        >,
        id : UUID
    ) -> DB_Folder? {
        for folder in ds.folders {
            if folder.id == id { return folder } else { continue }
        }
        for folder in ds.folders {
            if let f = getFolderIfExists(ds: folder, id: id) { return f } else { continue }
        }
        return nil
    }
    
    private static func getEntryIfExists(
        ds : DB_ME_DataStructure<
                String,
                Date,
                DB_Folder,
                DB_Entry,
                DB_LoadableResource,
                DB_CreditCard,
                DB_Note,
                DB_Passkey,
                UUID,
                DB_Tag
            >,
            id : UUID
    ) -> DB_Entry? {
        for entry in ds.entries {
            if entry.id == id { return entry } else { continue }
        }
        for folder in ds.folders {
            if let e = getEntryIfExists(ds: folder, id: id) { return e } else { continue }
        }
        return nil
    }

    /// Stores a document depending on the storage type
    private static func storeDocument(_ document : Encrypted_DB_Document, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Document, a Context must be provided to the storeDocument Function")
                try CoreDataManager.storeDocument(document, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeDocument(document, in: db)
        }
    }
    
    /// Stores an image depending on the storage type
    private static func storeImage(_ image : Encrypted_DB_Image, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Image, a Context must be provided to the storeImage Function")
                try CoreDataManager.storeImage(image, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeImage(image, in: db)
        }
    }
    
    /// Stores a video depending on the storage type
    private static func storeVideo(_ video : Encrypted_DB_Video, in db : EncryptedDatabase, context: NSManagedObjectContext?) throws -> Void {
        switch db.header.storageType {
            case .CoreData:
                assert(context != nil, "To store Core Data Video, a Context must be provided to the storeVideo Function")
                try CoreDataManager.storeVideo(video, context: context!)
            case .File:
                break
//                try DatabaseFileManager.storeVideo(video, in: db)
        }
    }
    
    internal static func deleteDatabase(id : UUID, with context : NSManagedObjectContext) throws -> Void {
        try CoreDataManager.deleteDatabase(id, with: context)
    }
    
//    internal static func deleteImage(id : UUID, in db : Database, with context : NSManagedObjectContext) throws -> Void {
//        try CoreDataManager.deleteImage(id: id, context: context)
//        try storeDatabase(db, context: context)
//    }
//    
//    internal static func deleteVideo(id : UUID, in db : Database, with context : NSManagedObjectContext) throws -> Void {
//        try CoreDataManager.deleteVideo(id: id, context: context)
//        try storeDatabase(db, context: context)
//    }
//    
//    internal static func deleteDocument(id : UUID, in db : Database, with context : NSManagedObjectContext) throws -> Void {
//        try CoreDataManager.deleteDocument(id: id, context: context)
//        try storeDatabase(db, context: context)
//    }
    
    /// Resets all Data of this App and the connected Cloud Container
    internal static func clearAll(context: NSManagedObjectContext) throws -> Void {
        try CoreDataManager.clearAll(context: context)
    }
}
