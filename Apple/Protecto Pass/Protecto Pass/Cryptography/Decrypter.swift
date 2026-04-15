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
import argon2

/// Decrypter to decrypt a Database and all it's components
internal final class Decrypter {

    /// The key vault used in this decrypters instance
    private let keyVault : SessionKeyVault

    internal init(keyVault: SessionKeyVault) {
        self.keyVault = keyVault
    }

    /* STATIC IMPLEMENTATION */
    // MARK: STATIC IMPLEMENTATION

    /// Derives the db wrapping key from the user password with the parameters provided by database header
    internal static func deriveKey(_ userPassword : SecureKeyBytes, header : DB_Header) throws -> SecureKeyBytes {
        // Create Argon2id context with arguments
        let ctx : UnsafeMutablePointer<argon2_context> = UnsafeMutablePointer.allocate(capacity: 1)
        // Free pointer after use
        defer {
            ctx.pointee.out.deallocate()
            ctx.pointee.pwd.deallocate()
            ctx.pointee.salt.deallocate()
//            ctx.pointee.secret.deallocate()
//            ctx.pointee.ad.deallocate()
        }
        var derived : SecureKeyBytes = SecureKeyBytes(count: Int(header.keyParameters.keyLength))
        // TODO: update pwd passing
        // Password
        ctx.pointee.pwd = userPassword
            .withUnsafeBytes(
                {
                    UnsafeMutablePointer<UInt8>(
                        mutating: UnsafePointer(
                            OpaquePointer($0.baseAddress)
                        )
                    )
                }
            )
        ctx.pointee.pwdlen = UInt32(userPassword.count)
        // Salt
        ctx.pointee.salt = header.salt.withUnsafeBytes(
            {
                UnsafeMutablePointer<UInt8>(
                    mutating: UnsafePointer(
                        OpaquePointer($0.baseAddress)
                    )
                )
            }
        )
        ctx.pointee.saltlen = UInt32(header.salt.count)
        // Parameters
        ctx.pointee.lanes = header.keyParameters.laneCount
        ctx.pointee.m_cost = header.keyParameters.memoryLimit
        ctx.pointee.t_cost = header.keyParameters.iterationsCount
        ctx.pointee.threads = header.keyParameters.threadCount
        ctx.pointee.version = header.keyParameters.argon2idVerson
        // Pointer to NULL so memory will be allocated internally
        ctx.pointee.allocate_cbk = nil
        ctx.pointee.free_cbk = nil
        // Out pointer
        ctx.pointee.out = derived.withUnsafeBytes(
            {
                UnsafeMutablePointer(
                    mutating: UnsafePointer(
                        OpaquePointer($0.baseAddress)
                    )
                )
            }
        )
        ctx.pointee.outlen = UInt32(derived.count)
        // TODO: add secret and associated data
        ctx.pointee.secret = nil
        ctx.pointee.secretlen = 0
        ctx.pointee.ad = nil
        ctx.pointee.adlen = 0
        // Argon2 type set to Argon2id
        let argon2id_type : argon2_type = argon2_type(2) // 2 is the identifier for argon2id
        // Get derived key
        let deriveStatus : Int32 = argon2_ctx(ctx, argon2id_type)
        guard deriveStatus == ARGON2_OK.rawValue else { throw CryptoError.errDerivation }
        return derived
    }

    /// Decrypts the Master Key with the provided DB Wrapping Key
    internal static func decryptMasterKey(
        header : DB_Header,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> SecureKeyBytes {
        if header.encryption == .AES256 {
            return try decryptAESKey(encryptedMasterKey: header.key, dbWrappingKeyBytes: dbWrappingKeyBytes)
        } else if header.encryption == .ChaChaPoly {
            return try decryptChaChaPolyKey(encryptedMasterKey: header.key, dbWrappingKeyBytes: dbWrappingKeyBytes)
        } else {
            throw CryptoError.unknownEncryption
        }
    }

    /* START GENERAL DECRYPTION */
    // MARK: GENERAL DECRYPTION

    /// Decrypts the passed database with the provided
    /// masterKey
    /// The `encryption` parameter defines the encryption being
    /// used to decrypt the database
    internal func decryptDatabase(
        _ database : EncryptedDatabase,
        encryption : Cryptography.Encryption
    ) throws -> Database {
        if encryption == .AES256 {
            return try decryptAES(database)
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly(database)
        } else {
            throw CryptoError.unknownEncryption
        }
    }

    /// Decryptes the passed image with the provided
    /// key.
    /// The `encryption` parameter defines the encryption being used
    /// to decrypt the image
    internal func decryptImage(
        _ image : Encrypted_DB_Image,
        encryption : Cryptography.Encryption
    ) throws -> DB_Image {
        if encryption == .AES256 {
            return try decryptAES(image: image)
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly(image: image)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Decryptes the passed video with the provided
    /// key.
    /// The `encryption` parameter defines the encryption being used
    /// to decrypt the video
    internal func decryptVideo(
        _ video : Encrypted_DB_Video,
        encryption : Cryptography.Encryption
    ) throws -> DB_Video {
        if encryption == .AES256 {
            return try decryptAES(video: video)
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly(video: video)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Decryptes the passed document with the provided
    /// key.
    /// The `encryption` parameter defines the encryption being used
    /// to decrypt the document
    internal func decryptDocument(
        _ document : Encrypted_DB_Document,
        encryption : Cryptography.Encryption
    ) throws -> DB_Document {
        if encryption == .AES256 {
            return try decryptAES(document: document)
        } else if encryption == .ChaChaPoly {
            return try decryptChaChaPoly(document: document)
        } else {
            throw CryptoError.unknownEncryption
        }
    }

    

    /* START AES DECRYPTION */
    // MARK: AES DECRYPTION

    /// Decrypts the key to use to decrypt the rest of the database using AES
    private static func decryptAESKey(
        encryptedMasterKey : Data,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> SecureKeyBytes {
        try dbWrappingKeyBytes.withUnsafeBytes {
            buffer in
            let data : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: encryptedMasterKey),
                using: SymmetricKey(
                    data: Data(
                        bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress)!,
                        count: buffer.count,
                        deallocator: .none
                    )
                ),
            )
            return try SecureKeyBytes(copying: data, count: data.count)
        }
    }

    /// Decrypts AES encrypted Databases
    private func decryptAES(_ database : EncryptedDatabase) throws -> Database {
        var decryptedFolders : [DB_Folder] = []
        for folder in database.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [DB_Entry] = []
        for entry in database.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [DB_LoadableResource] = []
        for image in database.images {
            decryptedImages.append(try decryptAES(lr: image))
        }
        var decryptedVideos : [DB_LoadableResource] = []
        for video in database.videos {
            decryptedVideos.append(try decryptAES(lr: video))
        }
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in database.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        var decryptedCreditCards : [DB_CreditCard] = []
        for card in database.creditCards {
            // TODO: implement credit card decrypt
        }
        var decryptedNotes : [DB_Note] = []
        for note in database.notes {
            // TODO: implement note decrypt
        }
        var decryptedPasskeys : [DB_Passkey] = []
        for passkey in database.passkeys {
            // TODO: implement passkey decrypt
        }
        return Database(
            decryptedName: database.name,
            decryptedDetails: database.details,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            creditCards: decryptedCreditCards,
            notes: decryptedNotes,
            passkeys: decryptedPasskeys,
            decryptedIconName: database.iconName,
            documents: decryptedDocuments,
            decryptedCreatedDate: database.createdDate,
            decryptedLastEditedDate: database.lastEditedDate,
            decryptedLastAccessedDate: database.lastAccessedDate,
            header: database.header,
            decryptedId: database.id
        )
    }
    
    /// Decrypts the passed Folder using AES and returns an decrypted Folder
    private func decryptAES(folder : Encrypted_DB_Folder) throws -> DB_Folder {
        var decryptedFolders : [DB_Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptAES(folder: folder))
        }
        var decryptedEntries : [DB_Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptAES(entry: entry))
        }
        var decryptedImages : [DB_LoadableResource] = []
        for image in folder.images {
            decryptedImages.append(try decryptAES(lr: image))
        }
        var decryptedVideos : [DB_LoadableResource] = []
        for video in folder.videos {
            decryptedVideos.append(try decryptAES(lr: video))
        }
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        var decryptedCreditCards : [DB_CreditCard] = []
        for card in folder.creditCards {
            // TODO: implement credit card decrypt
        }
        var decryptedNotes : [DB_Note] = []
        for note in folder.notes {
            // TODO: implement note decrypt
        }
        var decryptedPasskeys : [DB_Passkey] = []
        for passkey in folder.passkeys {
            // TODO: implement passkey decrypt
        }
        var decryptedTags : [DB_Tag] = []
        for tag in folder.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.name),
                using: key
            )
            let decryptedDetails : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.details),
                using: key
            )
            let decryptedIconName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.iconName),
                using: key
            )
            let decryptedCreatedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: folder.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: folder.id),
                using: key
            )
            return DB_Folder(
                name: DataConverter.dataToString(decryptedName),
                details: DataConverter.dataToString(decryptedDetails),
                folders: decryptedFolders,
                entries: decryptedEntries,
                images: decryptedImages,
                videos: decryptedVideos,
                creditCards: decryptedCreditCards,
                notes: decryptedNotes,
                passkeys: decryptedPasskeys,
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Entry using AES and returns and decrypted Entry
    private func decryptAES(entry : Encrypted_DB_Entry) throws -> DB_Entry {
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        var decryptedTags : [DB_Tag] = []
        for tag in entry.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedTitle : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.title),
                using: key
            )
            let decryptedDetails : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.details),
                using: key
            )
            let decryptedURL = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.url),
                using: key
            )
            let decryptedIconName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.iconName),
                using: key
            )
            let decryptedCreatedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.id),
                using: key
            )
            return DB_Entry(
                title: DataConverter.dataToString(decryptedTitle),
                encryptedUsername: entry.encryptedUsername, // Username and password stay encrypted until use
                encryptedPassword: entry.encryptedPassword,
                url: URL(string: DataConverter.dataToString(decryptedURL)),
                details: DataConverter.dataToString(decryptedDetails),
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Image using AES and returns a decrypted Image
    private func decryptAES(image : Encrypted_DB_Image) throws -> DB_Image {
        var decryptedTags : [DB_Tag] = []
        for tag in image.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: image.name),
                using: key
            )
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
                AES.GCM.SealedBox(combined: image.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: image.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: image.lastAccessedDate),
                using: key
            )
            return DB_Image(
                name: DataConverter.dataToString(decryptedName),
                image: UIImage(data: decryptedImageData)!,
                quality: decryptedQuality,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: image.id,
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Video using AES and returns a decrypted Image
    private func decryptAES(video : Encrypted_DB_Video) throws -> DB_Video {
        var decryptedTags : [DB_Tag] = []
        // TODO: pass key here? Key creation inside loop can create a lot of keys (even with short living period)
        for tag in video.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedVideoData : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: video.videoData),
                using: key
            )
            let decryptedCreatedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: video.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: video.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: video.lastAccessedDate),
                using: key
            )
            return DB_Video(
                videoData: decryptedVideoData,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: video.id,
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed document using AES and returns a decrypted Document
    private func decryptAES(document : Encrypted_DB_Document) throws -> DB_Document {
        var decryptedTags : [DB_Tag] = []
        for tag in document.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
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
                AES.GCM.SealedBox(combined: document.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: document.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: document.lastAccessedDate),
                using: key
            )
            return DB_Document(
                document: decryptedDocumentData,
                type: DataConverter.dataToString(decryptedType),
                name: DataConverter.dataToString(decryptedName),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: document.id,
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Loadable Resource using AES and returns a decrypted Loadable Resource
    private func decryptAES(lr : Encrypted_DB_LoadableResource) throws -> DB_LoadableResource {
        try keyVault.withKey {
            key in
            let decryptedNameData : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: lr.name ?? Data()),
                using: key
            )
            let decryptedThumbnailData : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: lr.thumbnailData),
                using: key
            )
            return DB_LoadableResource(
                id: lr.id,
                name: DataConverter.dataToString(decryptedNameData),
                thumbnailData: decryptedThumbnailData
            )
        }
    }

    private func decryptAES(creditCard : Encrypted_DB_CreditCard) throws -> DB_CreditCard {
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in creditCard.documents {
            decryptedDocuments.append(try decryptAES(lr: doc))
        }
        var decryptedTags : [DB_Tag] = []
        for tag in creditCard.tags {
            // TODO: implement tags
        }
        return try keyVault.withKey {
            key in
            let decryptedCardHolderName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: creditCard.cardHolderName),
                using: key
            )
            let decryptedIconName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: creditCard.iconName),
                using: key
            )
            let decryptedDetails : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: creditCard.details),
                using: key
            )
            let decryptedCreatedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: creditCard.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: creditCard.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: creditCard.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: creditCard.id),
                using: key
            )
            return DB_CreditCard(
                cardHolderName: DataConverter.dataToString(decryptedCardHolderName),
                encryptedCardNumber: creditCard.encryptedCardNumber,
                encryptedSecurityNumber: creditCard.encryptedSecurityNumber,
                encryptedExpirationDate: creditCard.encryptedExpirationDate,
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                details:  DataConverter.dataToString(decryptedDetails),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }

    private func decryptAES(note : Encrypted_DB_Note) throws -> DB_Note {
        var decryptedTags : [DB_Tag] = []
        for tag in note.tags {
            // TODO: implement tag decryption
        }
        return try keyVault.withKey {
            key in
            let decryptedContent : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: note.content),
                using: key
            )
            let decryptedCreatedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: note.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: note.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: note.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: note.id),
                using: key
            )
            return DB_Note(
                content: DataConverter.dataToString(decryptedContent),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }

//    private func decryptAES(passkey : Encrypted_DB_Passkey) throws -> DB_Passkey {
//
//    }

    private func decryptAES(tag : Encrypted_DB_Tag) throws -> DB_Tag {
        let decryptedColor : DB_Color = try decryptAES(color: tag.color)
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: tag.name),
                using: key
            )
            return DB_Tag(
                name: DataConverter.dataToString(decryptedName),
                color: decryptedColor
            )
        }
    }

    private func decryptAES(color : Encrypted_DB_Color) throws -> DB_Color {
        return try keyVault.withKey {
            key in
            let decryptedRed : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: color.red),
                using: key
            )
            let decryptedGreen : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: color.green),
                using: key
            )
            let decryptedBlue : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: color.blue),
                using: key
            )
            let decryptedAlpha : Data = try AES.GCM.open(
                AES.GCM.SealedBox(combined: color.alpha),
                using: key
            )
            return DB_Color(
                red: DataConverter.dataToInt(decryptedRed),
                green: DataConverter.dataToInt(decryptedGreen),
                blue: DataConverter.dataToInt(decryptedBlue),
                alpha: DataConverter.dataToInt(decryptedAlpha)
            )
        }
    }

    
    /* START CHACHAPOLY DECRYPTION */
    // MARK: CHACHAPOLY DECRYPTION

    /// Decrypts ChaChaPoly Encrypted Databases
    /// Throws an Error if something went wrong
    private func decryptChaChaPoly(_ database : EncryptedDatabase) throws -> Database {
        var decryptedFolders : [DB_Folder] = []
        for folder in database.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [DB_Entry] = []
        for entry in database.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [DB_LoadableResource] = []
        for image in database.images {
            decryptedImages.append(try decryptChaChaPoly(lr: image))
        }
        var decryptedVideos : [DB_LoadableResource] = []
        for video in database.videos {
            decryptedVideos.append(try decryptChaChaPoly(lr: video))
        }
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in database.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        var decryptedCreditCards : [DB_CreditCard] = []
        for card in database.creditCards {
            // TODO: implement credit card decrypt
        }
        var decryptedNotes : [DB_Note] = []
        for note in database.notes {
            // TODO: implement note decrypt
        }
        var decryptedPasskeys : [DB_Passkey] = []
        for passkey in database.passkeys {
            // TODO: implement passkey decrypt
        }
        let decryptedDatabase : Database = Database(
            decryptedName: database.name,
            decryptedDetails: database.details,
            folders: decryptedFolders,
            entries: decryptedEntries,
            images: decryptedImages,
            videos: decryptedVideos,
            creditCards: decryptedCreditCards,
            notes: decryptedNotes,
            passkeys: decryptedPasskeys,
            decryptedIconName: database.iconName,
            documents: decryptedDocuments,
            decryptedCreatedDate: database.createdDate,
            decryptedLastEditedDate: database.lastEditedDate,
            decryptedLastAccessedDate: database.lastAccessedDate,
            header: database.header,
            decryptedId: database.id
        )
        return decryptedDatabase
    }
    
    /// Decrypts the key to use to decrypt the rest of the database using ChaChaPoly
    private static func decryptChaChaPolyKey(
        encryptedMasterKey : Data,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> SecureKeyBytes {
        try dbWrappingKeyBytes.withUnsafeBytes {
            buffer in
            let data : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: encryptedMasterKey),
                using: SymmetricKey(
                    data: Data(
                        bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
                        count: buffer.count,
                        deallocator: .none
                    )
                )
            )
            return try SecureKeyBytes(copying: data, count: data.count)
        }
    }
    
    /// Decrypts the passed Folder with ChaChaPoly and returns
    /// an Folder
    private func decryptChaChaPoly(folder : Encrypted_DB_Folder) throws -> DB_Folder {
        var decryptedFolders : [DB_Folder] = []
        for folder in folder.folders {
            decryptedFolders.append(try decryptChaChaPoly(folder: folder))
        }
        var decryptedEntries : [DB_Entry] = []
        for entry in folder.entries {
            decryptedEntries.append(try decryptChaChaPoly(entry: entry))
        }
        var decryptedImages : [DB_LoadableResource] = []
        for image in folder.images {
            decryptedImages.append(try decryptChaChaPoly(lr: image))
        }
        var decryptedVideos : [DB_LoadableResource] = []
        for video in folder.videos {
            decryptedVideos.append(try decryptChaChaPoly(lr: video))
        }
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in folder.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        var decryptedCreditCards : [DB_CreditCard] = []
        for card in folder.creditCards {
            // TODO: implement credit card decrypt
        }
        var decryptedNotes : [DB_Note] = []
        for note in folder.notes {
            // TODO: implement note decrypt
        }
        var decryptedPasskeys : [DB_Passkey] = []
        for passkey in folder.passkeys {
            // TODO: implement passkey decrypt
        }
        var decryptedTags : [DB_Tag] = []
        for tag in folder.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.name),
                using: key
            )
            let decryptedDetails : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.details),
                using: key
            )
            let decryptedIconName : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.iconName),
                using: key
            )
            let decryptedCreatedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: folder.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: folder.id),
                using: key
            )
            return DB_Folder(
                name: DataConverter.dataToString(decryptedName),
                details: DataConverter.dataToString(decryptedDetails),
                folders: decryptedFolders,
                entries: decryptedEntries,
                images: decryptedImages,
                videos: decryptedVideos,
                creditCards: decryptedCreditCards,
                notes: decryptedNotes,
                passkeys: decryptedPasskeys,
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }
    
    /// Decryptes the passed Entry with ChaChaPoly and returns an Entry
    private func decryptChaChaPoly(entry : Encrypted_DB_Entry) throws -> DB_Entry {
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in entry.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        var decryptedTags : [DB_Tag] = []
        for tag in entry.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedTitle : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: entry.title),
                using: key
            )
            let decryptedDetails : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: entry.details),
                using: key
            )
            let decryptedURL = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: entry.url),
                using: key
            )
            let decryptedIconName : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: entry.iconName),
                using: key
            )
            let decryptedCreatedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: entry.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: entry.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: entry.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: entry.id),
                using: key
            )
            return DB_Entry(
                title: DataConverter.dataToString(decryptedTitle),
                encryptedUsername: entry.encryptedUsername, // Username and password stay encrypted until use
                encryptedPassword: entry.encryptedPassword,
                url: URL(string: DataConverter.dataToString(decryptedURL)),
                details: DataConverter.dataToString(decryptedDetails),
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }
    
    private func decryptChaChaPoly(image : Encrypted_DB_Image) throws -> DB_Image {
        var decryptedTags : [DB_Tag] = []
        for tag in image.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: image.name),
                using: key
            )
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
                ChaChaPoly.SealedBox(combined: image.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: image.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: image.lastAccessedDate),
                using: key
            )
            return DB_Image(
                name: DataConverter.dataToString(decryptedName),
                image: UIImage(data: decryptedImageData)!,
                quality: decryptedQuality,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: image.id,
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Video using ChaChaPoly and returns a decrypted Image
    private func decryptChaChaPoly(video : Encrypted_DB_Video) throws -> DB_Video {
        var decryptedTags : [DB_Tag] = []
        // TODO: pass key here? Key creation inside loop can create a lot of keys (even with short living period)
        for tag in video.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
            let decryptedVideoData : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: video.videoData),
                using: key
            )
            let decryptedCreatedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: video.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: video.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: video.lastAccessedDate),
                using: key
            )
            return DB_Video(
                videoData: decryptedVideoData,
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: video.id,
                tags: decryptedTags
            )
        }
    }
    
    private func decryptChaChaPoly(document : Encrypted_DB_Document) throws -> DB_Document {
        var decryptedTags : [DB_Tag] = []
        for tag in document.tags {
            // TODO: implement tag decrypt
        }
        return try keyVault.withKey {
            key in
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
                ChaChaPoly.SealedBox(combined: document.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: document.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: document.lastAccessedDate),
                using: key
            )
            return DB_Document(
                document: decryptedDocumentData,
                type: DataConverter.dataToString(decryptedType),
                name: DataConverter.dataToString(decryptedName),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: document.id,
                tags: decryptedTags
            )
        }
    }
    
    /// Decrypts the passed Loadable Resource using ChaChaPoly and returns a decrypted Loadable Resource
    private func decryptChaChaPoly(lr : Encrypted_DB_LoadableResource) throws -> DB_LoadableResource {
        try keyVault.withKey {
            key in
            let decryptedNameData : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: lr.name ?? Data()),
                using: key
            )
            let decryptedThumbnailData : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: lr.thumbnailData),
                using: key
            )
            return DB_LoadableResource(
                id: lr.id,
                name: DataConverter.dataToString(decryptedNameData),
                thumbnailData: decryptedThumbnailData
            )
        }
    }

    private func decryptChaChaPoly(creditCard : Encrypted_DB_CreditCard) throws -> DB_CreditCard {
        var decryptedDocuments : [DB_LoadableResource] = []
        for doc in creditCard.documents {
            decryptedDocuments.append(try decryptChaChaPoly(lr: doc))
        }
        var decryptedTags : [DB_Tag] = []
        for tag in creditCard.tags {
            // TODO: implement tags
        }
        return try keyVault.withKey {
            key in
            let decryptedCardHolderName : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: creditCard.cardHolderName),
                using: key
            )
            let decryptedIconName : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: creditCard.iconName),
                using: key
            )
            let decryptedDetails : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: creditCard.details),
                using: key
            )
            let decryptedCreatedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: creditCard.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: creditCard.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                try ChaChaPoly.SealedBox(combined: creditCard.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: creditCard.id),
                using: key
            )
            return DB_CreditCard(
                cardHolderName: DataConverter.dataToString(decryptedCardHolderName),
                encryptedCardNumber: creditCard.encryptedCardNumber,
                encryptedSecurityNumber: creditCard.encryptedSecurityNumber,
                encryptedExpirationDate: creditCard.encryptedExpirationDate,
                iconName: DataConverter.dataToString(decryptedIconName),
                documents: decryptedDocuments,
                details:  DataConverter.dataToString(decryptedDetails),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }

    private func decryptChaChaPoly(note : Encrypted_DB_Note) throws -> DB_Note {
        var decryptedTags : [DB_Tag] = []
        for tag in note.tags {
            // TODO: implement tag decryption
        }
        return try keyVault.withKey {
            key in
            let decryptedContent : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: note.content),
                using: key
            )
            let decryptedCreatedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: note.createdDate),
                using: key
            )
            let decryptedLastEditedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: note.lastEditedDate),
                using: key
            )
            let decryptedLastAccessedDate : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: note.lastAccessedDate),
                using: key
            )
            let decryptedId : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: note.id),
                using: key
            )
            return DB_Note(
                content: DataConverter.dataToString(decryptedContent),
                createdDate: try DataConverter.dataToDate(decryptedCreatedDate),
                lastEditedDate: try DataConverter.dataToDate(decryptedLastEditedDate),
                lastAccessedDate: try DataConverter.dataToDate(decryptedLastAccessedDate),
                id: DataConverter.dataToUUID(decryptedId),
                tags: decryptedTags
            )
        }
    }

//    private func decryptChaChaPoly(passkey : Encrypted_DB_Passkey) throws -> DB_Passkey {
//
//    }

    private func decryptChaChaPoly(tag : Encrypted_DB_Tag) throws -> DB_Tag {
        let decryptedColor : DB_Color = try decryptChaChaPoly(color: tag.color)
        return try keyVault.withKey {
            key in
            let decryptedName : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: tag.name),
                using: key
            )
            return DB_Tag(
                name: DataConverter.dataToString(decryptedName),
                color: decryptedColor
            )
        }
    }

    private func decryptChaChaPoly(color : Encrypted_DB_Color) throws -> DB_Color {
        return try keyVault.withKey {
            key in
            let decryptedRed : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: color.red),
                using: key
            )
            let decryptedGreen : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: color.green),
                using: key
            )
            let decryptedBlue : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: color.blue),
                using: key
            )
            let decryptedAlpha : Data = try ChaChaPoly.open(
                ChaChaPoly.SealedBox(combined: color.alpha),
                using: key
            )
            return DB_Color(
                red: DataConverter.dataToInt(decryptedRed),
                green: DataConverter.dataToInt(decryptedGreen),
                blue: DataConverter.dataToInt(decryptedBlue),
                alpha: DataConverter.dataToInt(decryptedAlpha)
            )
        }
    }

    deinit {
        // TODO: deinit decrypter
    }
}
