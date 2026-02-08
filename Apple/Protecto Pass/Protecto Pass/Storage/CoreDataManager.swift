//
//  CoreDataManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 25.08.23.
//

import Foundation
import CoreData

/// Struct used to interact with the Core Data Storage
internal struct CoreDataManager {
    
    /// Returns the fetch Request used to get the current Database with the provided ID
    private static func getFetchRequest(forDatabaseID id : UUID) -> NSFetchRequest<CD_Database> {
        let fetchRequest : NSFetchRequest = CD_Database.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Image with the provided ID
    private static func getFetchRequest(forImageID id : UUID) -> NSFetchRequest<CD_Image> {
        let fetchRequest : NSFetchRequest = CD_Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Video with the provided ID
    private static func getFetchRequest(forVideoID id : UUID) -> NSFetchRequest<CD_Video> {
        let fetchRequest : NSFetchRequest = CD_Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    /// Returns the fetch Request used to get the current Document with the provided ID
    private static func getFetchRequest(forDocumentID id : UUID) -> NSFetchRequest<CD_Document> {
        let fetchRequest : NSFetchRequest = CD_Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id as NSUUID)
        return fetchRequest
    }
    
    internal static func accessCache(id: UUID, context : NSManagedObjectContext) throws -> CD_Database {
        guard try databaseExists(id: id, context: context) else {
            throw DatabaseDoesNotExistError()
        }
        return try context.fetch(getFetchRequest(forDatabaseID: id)).first!
    }
    
    internal static func databaseExists(id : UUID, context : NSManagedObjectContext) throws -> Bool {
        return try !context.fetch(getFetchRequest(forDatabaseID: id)).isEmpty
    }
    
    /// Loads all Databases from the Core Data System
    internal static func load(with context : NSManagedObjectContext) throws -> [EncryptedDatabase] {
        let databases : [CD_Database] = try context.fetch(CD_Database.fetchRequest())
        let encryptedDatabases : [EncryptedDatabase] = try DB_Converter.fromCD(databases)
        return encryptedDatabases
    }
    
    internal static func loadImages(_ db : Database, ids: [UUID], with context : NSManagedObjectContext) throws -> [DB_Image] {
        var results : [DB_Image] = []
        for imageID in ids {
            let cdImage = try context.fetch(getFetchRequest(forImageID: imageID)).first!
            let im = try ImageConverter.fromCD(cdImage)
            let decryptedImage = try Decrypter.decryptImage(im, in: db)
            results.append(decryptedImage)
        }
        return results
    }
    
    internal static func loadVideos(_ db : Database, ids: [UUID], with context : NSManagedObjectContext) throws -> [DB_Video] {
        var results : [DB_Video] = []
        for vID in ids {
            let cdVideo = try context.fetch(getFetchRequest(forVideoID: vID)).first!
            let vid = try VideoConterter.fromCD(cdVideo)
            let decryptedVideo = try Decrypter.decryptVideo(vid, in: db)
            results.append(decryptedVideo)
        }
        return results
    }
    
    internal static func loadDocuments(_ db : Database, ids: [UUID], with context : NSManagedObjectContext) throws -> [DB_Document] {
        var results : [DB_Document] = []
        for dID in ids {
            let cdDocument = try context.fetch(getFetchRequest(forDocumentID: dID)).first!
            let doc = try DocumentConverter.fromCD(cdDocument)
            let decryptedDocument = try Decrypter.decryptDocument(doc, in: db)
            results.append(decryptedDocument)
        }
        return results
    }
    
    /// Stores the Database to the Core Data System
    internal static func storeDatabase(_ db : EncryptedDatabase, context : NSManagedObjectContext) throws -> Void {
        if try databaseExists(id: db.id, context: context) {
            try deleteDatabaseMeta(db.id, with: context)
        }
        // Store Database including folders and entries, loadable Resource references are stored in this too, the actual resources are stored on adding them to the Database
        let _ = DB_Converter.toCD(db, context: context)
        try context.save()
    }
    
    internal static func storeImage(_ image : Encrypted_DB_Image, context : NSManagedObjectContext) throws -> Void {
        let _ = ImageConverter.toCD(image, context: context)
        try context.save()
    }
    
    internal static func storeVideo(_ video : Encrypted_DB_Video, context : NSManagedObjectContext) throws -> Void {
        let _ = VideoConterter.toCD(video, context: context)
        try context.save()
    }
    
    internal static func storeDocument(_ document : Encrypted_DB_Document, context : NSManagedObjectContext) throws -> Void {
        let _ = DocumentConverter.toCD(document, context: context)
        try context.save()
    }
    
    /// Only deletes the Database Meta or Base data, letting images, documents and videos remain
    internal static func deleteDatabaseMeta(_ id : UUID, with context : NSManagedObjectContext) throws -> Void {
        let db : CD_Database = try accessCache(id: id, context: context)
        let _ = try DB_Converter.fromCD(db)
        context.delete(try accessCache(id: id, context: context))
    }
    
    internal static func deleteDatabase(_ id : UUID, with context : NSManagedObjectContext) throws -> Void {
        let db : CD_Database = try accessCache(id: id, context: context)
        let encrypted = try DB_Converter.fromCD(db)
        context.delete(db)
        for image in encrypted.images {
            try deleteImage(id: image.id, context: context)
        }
        for video in encrypted.videos {
            try deleteVideo(id: video.id, context: context)
        }
        for document in encrypted.documents {
            try deleteDocument(id: document.id, context: context)
        }
        try context.save()
    }
    
    internal static func deleteImage(id : UUID, context : NSManagedObjectContext) throws -> Void {
        let cdImage = try context.fetch(getFetchRequest(forImageID: id)).first!
        context.delete(cdImage)
        // TODO: store Database
        try context.save()
    }
    
    internal static func deleteVideo(id : UUID, context : NSManagedObjectContext) throws -> Void {
        let cdVideo = try context.fetch(getFetchRequest(forVideoID: id)).first!
        context.delete(cdVideo)
        try context.save()
    }
    
    internal static func deleteDocument(id : UUID, context : NSManagedObjectContext) throws -> Void {
        let cdDocument = try context.fetch(getFetchRequest(forDocumentID: id)).first!
        context.delete(cdDocument)
        try context.save()
    }
    
    internal static func clearAll(context : NSManagedObjectContext) throws -> Void {
        let allDatabases : [EncryptedDatabase] = try load(with: context)
        for db in allDatabases {
            try deleteDatabase(db.id, with: context)
        }
    }
}
