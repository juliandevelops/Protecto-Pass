//
//  Decrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Decoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Decrypter.swift on 27.05.23.
//

import CommonCrypto
import CryptoKit
import Foundation
import UIKit

/// Decrypter to decrypt a Database and all it's components
internal struct Decrypter {
    
    /// Decrypter specified for AES 256 Bit Encryption
    private static let aes256 : Decrypter = Decrypter(encryption: .AES256)
    
    /// Decrypter specified for ChaChaPoly Encryption
    private static let chaChaPoly : Decrypter = Decrypter(encryption: .ChaChaPoly)
    
    /// Returns the correct Decrypter for the passed database
    internal static func configure(for db : EncryptedDatabase, with password : String) -> Decrypter {
        var decrypter : Decrypter
        if db.header.encryption == .AES256 {
            decrypter = aes256
        } else if db.header.encryption == .ChaChaPoly {
            decrypter = chaChaPoly
        } else {
            decrypter = Decrypter(encryption: nil)
        }
        decrypter.db = db
        return decrypter
    }
    
    /// The Encryption that is used for this Decrypter
    private let encryption : Cryptography.Encryption?
    
    /// The Database that should be decrypted.
    /// This is passed with the decrypt Method,
    /// and is used by the private methods
    private var db : EncryptedDatabase?
    
    /// This is the symmetric Key used to
    /// decrypt the Database
    private var key : SymmetricKey?
    
    /// Private init, to prevent creating this Object.
    /// Only use getInstance with the database you want to decrypt
    private init(encryption : Cryptography.Encryption?) {
        self.encryption = encryption
    }
    
    // START GENERAL DECRYPTION
    
    internal mutating func decrypt() throws -> Database {
        if db!.header.encryption == .AES256 {
            return try decryptAES()
        } else if db!.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly()
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Image with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal static func decryptImage(_ image : Encrypted_DB_Image, in db : Database) throws -> DB_Image {
        if db.header.encryption == .AES256 {
            return try decryptAES(image: image, key: db.key)
        } else if db.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(image: image, key: db.key)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Video with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal static func decryptVideo(_ video : Encrypted_DB_Video, in db : Database) throws -> DB_Video {
        if db.header.encryption == .AES256 {
            return try decryptAES(video: video, key: db.key)
        } else if db.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(video: video, key: db.key)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Decrypts the passed Document with the cryptography algorithm this Decrypter is configured for.
    /// Use the `configure` Method to configure a Decrypter
    internal static func decryptDocument(_ document : Encrypted_DB_Document, in db : Database) throws -> DB_Document {
        if db.header.encryption == .AES256 {
            return try decryptAES(document: document, key: db.key)
        } else if db.header.encryption == .ChaChaPoly {
            return try decryptChaChaPoly(document: document, key : db.key)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    // START AES DECRYPTION

    /// Derives the Key from User Password with secure hasing
    private func deriveKey() throws -> Data {
        let data = Data(userPassword!.utf8)
        var derived = Data(repeating: 0, count: Int(db!.header.keyLength))
        let salt : Data = db!.header.salt
        let status = derived.withUnsafeMutableBytes { derivedBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    (userPassword! as NSString).utf8String, data.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress!, salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(db!.header.iterationsCount),
                    derivedBytes.bindMemory(to: UInt8.self).baseAddress!, Int(db!.header.keyLength)
                )
            }
        }
        guard status == kCCSuccess else { throw CryptoError.errUnlocking }
        return derived
    }

    /// Decrypts the key to use to decrypt the rest of the database using AES
    private func decryptAESKey() throws -> SymmetricKey {
        let data : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: db!.header.key),
            using: key)
        )
        return SymmetricKey(data: data)
    }

    /// Decrypts AES encrypted Databases
    private mutating func decryptAES() throws -> Database {
        key = try decryptAESKey()
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in db!.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [LoadableResource] = []
        for image in db!.images {
            decryptedImages.append(try decryptAES(lr: image))
        }
        var decryptedVideos : [LoadableResource] = []
        for video in db!.videos {
            decryptedVideos.append(try decryptAES(lr: video))
        }
        var decryptedDocuments : [LoadableResource] = []
        for doc in db!.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        return Database(
            name: db!.name,
            description: db!.description,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            iconName: db!.iconName,
            documents: decryptedDocuments,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: key!,
            password: userPassword!,
            allowBiometrics: db!.allowBiometrics,
            id: db!.id
        )
    }
    
    /// Decrypts the passed Folder using AES and returns an decrypted Folder
    private func decryptAES(folder : EncryptedFolder) throws -> Folder {
        var decryptedFolders : [Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [LoadableResource] = []
        for image in folder.images {
            decryptedImages.append(try decryptAES(lr: image))
        }
        var decryptedVideos : [LoadableResource] = []
        for video in folder.videos {
            decryptedVideos.append(try decryptAES(lr: video))
        }
        var decryptedDocuments : [LoadableResource] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        let decryptedName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedDescription : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.description),
            using: key!
        )
        let decryptedIconName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: folder.lastEdited),
            using: key!
        )
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: folder.id
        )
    }
    
    /// Decrypts the passed Entry using AES and returns and decrypted Entry
    private func decryptAES(entry : EncryptedEntry) throws -> Entry {
        var decryptedDocuments : [LoadableResource] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        let decryptedTitle : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.title),
            using: key!
        )
        let decryptedUsername : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.username),
            using: key!
        )
        let decryptedPassword = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.password),
            using: key!
        )
        let decryptedURL = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.url),
            using: key!
        )
        let decryptedNotes : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.notes),
            using: key!
        )
        let decryptedIconName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: entry.lastEdited),
            using: key!
        )
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: entry.id
        )
    }
    
    /// Decrypts the passed Image using AES and returns a decrypted Image
    private static func decryptAES(image : Encrypted_DB_Image, key : SymmetricKey) throws -> DB_Image {
        let decryptedImageData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: image.image),
            using: key
        )
        let decryptedQuality : Double = DataConverter.dataToDouble(
            try AES.GCM.open(
                AES.GCM.SealedBox(combined: image.quality),
                using: key
            )
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: image.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: image.lastEdited),
            using: key
        )
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: image.id
        )
    }
    
    /// Decrypts the passed Video using AES and returns a decrypted Image
    private static func decryptAES(video : Encrypted_DB_Video, key : SymmetricKey) throws -> DB_Video {
        let decryptedVideoData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: video.video),
            using: key
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: video.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: video.lastEdited),
            using: key
        )
        return DB_Video(
            video: decryptedVideoData,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: video.id
        )
    }
    
    /// Decrypts the passed document using AES and returns a decrypted Document
    private static func decryptAES(document : Encrypted_DB_Document, key : SymmetricKey) throws -> DB_Document {
        let decryptedDocumentData : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.document),
            using: key
        )
        let decryptedType : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.type),
            using: key
        )
        let decryptedName : Data = try AES.GCM.open(
            try AES.GCM.SealedBox(combined: document.name),
            using: key
        )
        let decryptedCreatedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: document.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: document.lastEdited),
            using: key
        )
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            name: DataConverter.dataToString(decryptedName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: document.id
        )
    }
    
    /// Decrypts the passed Loadable Resource using AES and returns a decrypted Loadable Resource
    private func decryptAES(lr : EncryptedLoadableResource) throws -> LoadableResource {
        let decryptedNameData : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: lr.name ?? Data()),
            using: key!
        )
        let decryptedThumbnailData : Data = try AES.GCM.open(
            AES.GCM.SealedBox(combined: lr.thumbnailData),
            using: key!
        )
        return LoadableResource(
            id: lr.id,
            name: DataConverter.dataToString(decryptedNameData),
            thumbnailData: decryptedThumbnailData
        )
    }
    
    
    // START ChaChaPoly DECRYPTION
    
    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private mutating func decryptChaChaPoly() throws -> Database {
        key = try decryptChaChaPolyKey()
        var decryptedFolders : [Folder] = []
        for folder in db!.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in db!.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [LoadableResource] = []
        for image in db!.images {
            decryptedImages.append(try decryptChaChaPoly(lr: image))
        }
        var decryptedVideos : [LoadableResource] = []
        for video in db!.videos {
            decryptedVideos.append(try decryptChaChaPoly(lr: video))
        }
        var decryptedDocuments : [LoadableResource] = []
        for doc in db!.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        let decryptedDatabase : Database = Database(
            name: db!.name,
            description: db!.description,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            iconName: db!.iconName,
            documents: decryptedDocuments,
            created: db!.created,
            lastEdited: db!.lastEdited,
            header: db!.header,
            key: key!,
            id: db!.id
        )
        return decryptedDatabase
    }
    
    /// Decrypts the key to use to decrypt the rest of the database using ChaChaPoly
    private func decryptChaChaPolyKey() throws -> SymmetricKey {
        let data : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: db!.header.key),
            using: SymmetricKey(data: Cryptography.sha256HashBytes(password!))
        )
        return SymmetricKey(data: data)
    }
    
    /// Decrypts the passed Folder with ChaChaPoly and returns
    /// an Folder
    private func decryptChaChaPoly(folder : EncryptedFolder) throws -> Folder {
        var decryptedFolders : [Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [LoadableResource] = []
        for image in folder.images {
            decryptedImages.append(try decryptChaChaPoly(lr: image))
        }
        var decryptedVideos : [LoadableResource] = []
        for video in folder.videos {
            decryptedVideos.append(try decryptChaChaPoly(lr: video))
        }
        var decryptedDocuments : [LoadableResource] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        let decryptedName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.name),
            using: key!
        )
        let decryptedDescription : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.description),
            using: key!
        )
        let decryptedIconName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: folder.lastEdited),
            using: key!
        )
        return Folder(
            name: DataConverter.dataToString(decryptedName),
            description: DataConverter.dataToString(decryptedDescription),
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: folder.id
        )
    }
    
    /// Decryptes the passed Entry with ChaChaPoly and returns an Entry
    private func decryptChaChaPoly(entry : EncryptedEntry) throws -> Entry {
        var decryptedDocuments : [LoadableResource] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        let decryptedTitle : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.title),
            using: key!
        )
        let decryptedUsername : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.username),
            using: key!
        )
        let decryptedPassword = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.password),
            using: key!
        )
        let decryptedURL = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.url),
            using: key!
        )
        let decryptedNotes : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: entry.notes),
            using: key!
        )
        let decryptedIconName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.iconName),
            using: key!
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.created),
            using: key!
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: entry.lastEdited),
            using: key!
        )
        return Entry(
            title: DataConverter.dataToString(decryptedTitle),
            username: DataConverter.dataToString(decryptedUsername),
            password: DataConverter.dataToString(decryptedPassword),
            url: URL(string: DataConverter.dataToString(decryptedURL)),
            notes: DataConverter.dataToString(decryptedNotes),
            iconName: DataConverter.dataToString(decryptedIconName),
            documents: decryptedDocuments,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: entry.id
        )
    }
    
    private static func decryptChaChaPoly(image : Encrypted_DB_Image, key : SymmetricKey) throws -> DB_Image {
        let decryptedImageData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: image.image),
            using: key
        )
        let decryptedQuality : Double = DataConverter.dataToDouble(
            try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: image.quality),
                using: key
            )
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: image.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: image.lastEdited),
            using: key
        )
        return DB_Image(
            image: UIImage(data: decryptedImageData)!,
            quality: decryptedQuality,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: image.id
        )
    }
    
    /// Decrypts the passed Video using ChaChaPoly and returns a decrypted Image
    private static func decryptChaChaPoly(video : Encrypted_DB_Video, key : SymmetricKey) throws -> DB_Video {
        let decryptedVideoData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.video),
            using: key
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: video.lastEdited),
            using: key
        )
        return DB_Video(
            video: decryptedVideoData,
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: video.id
        )
    }
    
    private static func decryptChaChaPoly(document : Encrypted_DB_Document, key : SymmetricKey) throws -> DB_Document {
        let decryptedDocumentData : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: document.document),
            using: key
        )
        let decryptedType : Data = try ChaChaPoly.open(
            try ChaChaPoly.SealedBox(combined: document.type),
            using: key
        )
        let decryptedName : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.name),
            using: key
        )
        let decryptedCreatedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.created),
            using: key
        )
        let decryptedLastEditedDate : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: document.lastEdited),
            using: key
        )
        return DB_Document(
            document: decryptedDocumentData,
            type: DataConverter.dataToString(decryptedType),
            name : DataConverter.dataToString(decryptedName),
            created: try DataConverter.dataToDate(decryptedCreatedDate),
            lastEdited: try DataConverter.dataToDate(decryptedLastEditedDate),
            id: document.id
        )
    }
    
    /// Decrypts the passed Loadable Resource using ChaChaPoly and returns a decrypted Loadable Resource
    private func decryptChaChaPoly(lr : EncryptedLoadableResource) throws -> LoadableResource {
        let decryptedNameData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: lr.name ?? Data()),
            using: key!
        )
        let decryptedThumbnailData : Data = try ChaChaPoly.open(
            ChaChaPoly.SealedBox(combined: lr.thumbnailData),
            using: key!
        )
        return LoadableResource(
            id: lr.id,
            name: DataConverter.dataToString(decryptedNameData),
            thumbnailData: decryptedThumbnailData
        )
    }
}
