//
//  DatabaseFileManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FileManager.swift on 28.03.23.
//
//  Renamed by Julian Schumacher to DatabaseFileManager.swift on 27.08.23.
//

import Foundation
import CoreData

/// The Struct controlling reading and writing
/// from and to a file, if the user selected that he wants
/// this safe to be stored as a file
internal struct DatabaseFileManager
//: DatabaseCache
{
    
    
//    
//    static func accessCache(id: UUID) throws -> EncryptedDatabase {
//        // TODO: needed?
//        return EncryptedDatabase.previewDB
//    }
//    
//    
//    static func databaseExists(id: UUID) throws -> Bool {
//        // TODO: needed?
//        return true
//    }
//    
//    
//    internal static var paths: [URL] = []
//    
//    internal static func load(from paths : [URL]) throws -> [EncryptedDatabase] {
//        var databases : [EncryptedDatabase] = []
//        let jsonDecoder : JSONDecoder = JSONDecoder()
//        for path in paths {
//            let dbData : Data = try Data(contentsOf: path)
//            let jsonDB : EncryptedDatabase = try jsonDecoder.decode(EncryptedDatabase.self, from: dbData)
//            databases.append(jsonDB)
//        }
//        databases = databases.sorted { $0.lastEdited > $1.lastEdited }
//        return databases
//    }
//    
//    internal static func storeDatabase(_ db : EncryptedDatabase) throws -> Void {
//        guard let url : URL = db.header.path else {
//            throw NonexistentPathError()
//        }
//        // TODO: requires secure coding?
//        let unarchiver : NSKeyedUnarchiver = try NSKeyedUnarchiver(forReadingFrom: NSData(contentsOf: url).decompressed(using: .lzfse) as Data)
//        unarchiver.requiresSecureCoding = true
//        unarchiver.decodingFailurePolicy = .raiseException
//        let archiver : NSKeyedArchiver = NSKeyedArchiver(requiringSecureCoding: true)
//        archiver.outputFormat = .binary
//        archiver.requiresSecureCoding = true
//        // Pre: Elements all stored in Sandbox as "working directory". At every storing process the following happens:
//        // 1. Read Element from Sandbox
//        // 2. Store Element into archiver
//        // 3. Store archiver
//        try archiver.encodeEncodable(db, forKey: "db")
//        // TODO: resources are not stored yet
//        archiver.finishEncoding()
//        try (archiver.encodedData as NSData).compressed(using: .lzfse).write(to: url, options: [.atomic, .completeFileProtection])
//    }
//    
//    internal static func storeDocument(_ document : Encrypted_DB_Document, in db : EncryptedDatabase) throws -> Void {
//        for folder in db.folders {
//            checkForDocumentPosition(document, in: folder)
//        }
//        //try SandboxManager.storeDocument(document, at: )
//    }
//    
//    private static func checkForDocumentPosition(_ document : Encrypted_DB_Document, in db : EncryptedFolder) -> EncryptedFolder {
//        for folder in db.folders {
//            if folder.documents.contains(where: { $0.id == document.id }) {
//                return folder
//            } else {
//                return checkForDocumentPosition(document, in: folder)
//            }
//        }
//        
//    }
//    
//    internal static func storeImage(_ image : Encrypted_DB_Image, in db : EncryptedDatabase) throws -> Void {
//         
//    }
//    
//    internal static func storeVideo(_ video : Encrypted_DB_Video, in db : EncryptedDatabase) throws -> Void {
//        
//    }
//    
//    // TODO: change to either 'id' or 'path'. Path is better, because it actually represents the location of the database, rather than its id which has to be searched
//    internal static func deleteDatabase(_ id : UUID? = nil, at path : URL? = nil) {
//        
//    }
}
