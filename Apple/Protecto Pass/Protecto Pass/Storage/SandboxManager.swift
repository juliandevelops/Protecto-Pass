//
//  SandboxManager.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.04.24.
//

import Foundation

internal struct SandboxManager {
    
//    private static let fileManager : FileManager = FileManager.default
//    
//    private static let tempDir : URL = fileManager.temporaryDirectory
//    
//    private static let jsonEncoder : JSONEncoder = JSONEncoder()
//    
//    internal static func loadToSandbox(
//        forDB db : EncryptedDatabase,
//        documents : [Encrypted_DB_Document],
//        images : [Encrypted_DB_Image],
//        videos : [Encrypted_DB_Video]
//    ) throws -> Void {
//        let rootDir : URL = tempDir.appendingPathExtension(db.id.uuidString)
//        try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true)
//        for folder in db.folders {
//            try storeFolder(folder, at: rootDir)
//        }
//        for entry in db.entries {
//            try storeEntry(entry, at: rootDir)
//        }
//        for document in documents {
//            try storeDocument(document, at: rootDir)
//        }
//        for image in images {
//            try storeImage(image, at: rootDir)
//        }
//        for video in videos {
//            try storeVideo(video, at: rootDir)
//        }
//    }
//    
//    private static func storeFolder(_ folder : EncryptedFolder, at rootDir : URL) throws -> Void {
//        let folderPath : URL = rootDir.appendingPathExtension(folder.id.uuidString)
//        try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: false)
//        for folder in folder.folders {
//            try storeFolder(folder, at: folderPath)
//        }
//        for entry in folder.entries {
//            try storeEntry(entry, at: folderPath)
//        }
//        for document in folder.documents {
//            try storeDocument(document, at: folderPath)
//        }
//        for image in folder.images {
//            try storeImage(image, at: folderPath)
//        }
//        for video in folder.videos {
//            try storeVideo(video, at: folderPath)
//        }
//    }
//    
//    internal static func storeEntry(_ entry : EncryptedEntry, at rootDir : URL) throws -> Void {
//        let entryPath : URL = rootDir.appendingPathExtension(entry.id.uuidString)
//        fileManager.createFile(atPath: entryPath.absoluteString, contents: try jsonEncoder.encode(entry).base64EncodedData())
//    }
//    
//    internal static func storeDocument(_ document : Encrypted_DB_Document, at rootDir : URL) throws -> Void {
//        let documentPath : URL = rootDir.appendingPathExtension(document.id.uuidString)
//        fileManager.createFile(atPath: documentPath.absoluteString, contents: try jsonEncoder.encode(document).base64EncodedData())
//    }
//    
////    internal static func storeDocument(_ document : Encrypted_DB_Document, in folder : EncryptedFolder) -> Void {
////        for directory in fileManager. {
////            
////        }
////        let documentPath : URL = rootDir.appendingPathExtension(document.id.uuidString)
////        // TODO: add content
////        fileManager.createFile(atPath: documentPath.absoluteString, contents: Data())
////    }
//    
//    internal static func storeImage(_ image : Encrypted_DB_Image, at rootDir : URL) throws -> Void {
//        let imagePath : URL = rootDir.appendingPathExtension(image.id.uuidString)
//        fileManager.createFile(atPath: imagePath.absoluteString, contents: try jsonEncoder.encode(image).base64EncodedData())
//    }
//    
//    internal static func storeVideo(_ video : Encrypted_DB_Video, at rootDir : URL) throws -> Void {
//        let videoPath : URL = rootDir.appendingPathExtension(video.id.uuidString)
//        fileManager.createFile(atPath: videoPath.absoluteString, contents: try jsonEncoder.encode(video).base64EncodedData())
//    }
//    
//    internal static func clearSandbox() throws -> Void {
//        try fileManager.removeItem(at: tempDir) // TODO: does this work?
//    }
}
