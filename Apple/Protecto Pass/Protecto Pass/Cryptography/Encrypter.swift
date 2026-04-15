//
//  Encrypter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as Encoder.swift on 07.05.23.
//
//  Renamed by Julian Schumacher to Encrypter.swift on 27.05.23.
//

import CryptoKit
import Foundation

/// Struct used to encrypt Databases and their components
/// into encrypted Databases
internal final class Encrypter {

    /// The key vault used in this encrypters instance
    private let keyVault : SessionKeyVault

    internal init(keyVault : SessionKeyVault) {
        self.keyVault = keyVault
    }

    /* START GENERAL ENCRYPTION */
    // MARK: GENERAL ENCRYPTION


    internal func encryptDatabase(
        _ database : Database,
        encryption : Cryptography.Encryption
    ) throws -> EncryptedDatabase {
        if encryption == .AES256 {
            return try encryptAES(database)
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly(database)
        } else {
            throw CryptoError.unknownEncryption
        }
    }

    /// Encrypts the passed Image with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func encryptImage(
        _ image : DB_Image,
        encryption : Cryptography.Encryption
    ) throws -> Encrypted_DB_Image {
        if encryption == .AES256 {
            return try encryptAES(image: image)
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly(image: image)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Encrypts the passed Video with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func encryptVideo(
        _ video : DB_Video,
        encryption : Cryptography.Encryption
    ) throws -> Encrypted_DB_Video {
        if encryption == .AES256 {
            return try encryptAES(video: video)
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly(video: video)
        } else {
            throw CryptoError.unknownEncryption
        }
    }
    
    /// Encrypts the passed Document with the cryptography algorithm this Encrypter is configured for.
    /// Use the `configure` Method to configure a Encrypter
    internal func encryptDocument(
        _ document : DB_Document,
        encryption : Cryptography.Encryption
    ) throws -> Encrypted_DB_Document {
        if encryption == .AES256 {
            return try encryptAES(document: document)
        } else if encryption == .ChaChaPoly {
            return try encryptChaChaPoly(document: document)
        } else {
            throw CryptoError.unknownEncryption
        }
    }

    internal func encryptMasterKey(
        header : DB_Header,
        decryptedMasterKey : SecureKeyBytes,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> Data {
        switch header.encryption {
        case .AES256:
            return try Encrypter.encryptAESKey(
                decryptedMasterKey: decryptedMasterKey,
                dbWrappingKeyBytes: dbWrappingKeyBytes
            )
        case .ChaChaPoly:
            return try Encrypter.encryptChaChaPolyKey(
                decryptedMasterKey: decryptedMasterKey,
                dbWrappingKeyBytes: dbWrappingKeyBytes
            )
        default:
            throw CryptoError.unknownEncryption
        }
    }

    /* START AES ENCRYPTION */
    // MARK: AES ENCRYPTION

    private static func encryptAESKey(
        decryptedMasterKey : SecureKeyBytes,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> Data {
        return try dbWrappingKeyBytes.withUnsafeBytes {
            buffer in
            try decryptedMasterKey.withUnsafeBytes {
                masterKeyBuffer in
                let encrypted : Data = try AES.GCM.seal(
                    Data(
                        bytesNoCopy: UnsafeMutableRawPointer(mutating: masterKeyBuffer.baseAddress!),
                        count: masterKeyBuffer.count,
                        deallocator: .none
                    ),
                    using: SymmetricKey(
                        data: Data(
                            bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
                            count: buffer.count,
                            deallocator: .none
                        )
                    )
                ).combined!
                return encrypted
            }
        }
    }

    /// Encrypts Databases with AES
    /// Throws an Error if something went wrong
    private func encryptAES(_ database : Database) throws -> EncryptedDatabase {
        var encryptedFolders : [Encrypted_DB_Folder] = []
        for folder in database.folders {
            encryptedFolders.append(try encryptAES(folder: folder))
        }
        var encryptedEntries : [Encrypted_DB_Entry] = []
        for entry in database.entries {
            encryptedEntries.append(try encryptAES(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_LoadableResource] = []
        for image in database.images {
            encryptedImages.append(try encryptAES(lr: image))
        }
        var encryptedVideos : [Encrypted_DB_LoadableResource] = []
        for video in database.videos {
            encryptedVideos.append(try encryptAES(lr: video))
        }
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in database.documents {
            encryptedDocuments.append(try encryptAES(lr: doc))
        }
        var encryptedCreditCards : [Encrypted_DB_CreditCard] = []
        for card in database.creditCards {
            // TODO: implement credit card encrypt
        }
        var encryptedNotes : [Encrypted_DB_Note] = []
        for note in database.notes {

        }
        var encryptedPasskeys : [Encrypted_DB_Passkey] = []
        for passkey in encryptedPasskeys {

        }
        return EncryptedDatabase(
            decryptedName: database.name,
            decryptedDetails: database.details,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            videos: encryptedVideos,
            creditCards: encryptedCreditCards,
            notes: encryptedNotes,
            passkeys : encryptedPasskeys,
            decryptedIconName: database.iconName,
            documents: encryptedDocuments,
            decryptedCreatedDate: database.createdDate,
            decryptedLastEditedDate: database.lastEditedDate,
            decryptedLastAccessedDate: database.lastAccessedDate,
            header: database.header,
            decryptedId: database.id
        )
    }
    
    /// Encrypts the passed Folder with AES and returns
    /// an encrypted Folder
    private func encryptAES(folder : DB_Folder) throws -> Encrypted_DB_Folder {
        var encryptedFolders : [Encrypted_DB_Folder] = []
        for folder in folder.folders {
            encryptedFolders.append(try encryptAES(folder: folder))
        }
        var encryptedEntries : [Encrypted_DB_Entry] = []
        for entry in folder.entries {
            encryptedEntries.append(try encryptAES(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_LoadableResource] = []
        for image in folder.images {
            encryptedImages.append(try encryptAES(lr: image))
        }
        var encryptedVideos : [Encrypted_DB_LoadableResource] = []
        for video in folder.videos {
            encryptedVideos.append(try encryptAES(lr: video))
        }
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in folder.documents {
            encryptedDocuments.append(try encryptAES(lr: doc))
        }
        var encryptedCreditCards : [Encrypted_DB_CreditCard] = []
        for card in folder.creditCards {

        }
        var encryptedNotes : [Encrypted_DB_Note] = []
        for note in folder.notes {

        }
        var encryptedPasskeys : [Encrypted_DB_Passkey] = []
        for passkey in folder.passkeys {

        }
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in folder.tags {

        }
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try AES.GCM.seal(
                DataConverter.stringToData(folder.name),
                using: key
            ).combined!
            let encryptedDetails : Data = try AES.GCM.seal(
                DataConverter.stringToData(folder.details),
                using: key
            ).combined!
            let encryptedIconName : Data = try AES.GCM.seal(
                DataConverter.stringToData(folder.iconName),
                using: key
            ).combined!
            let encryptedCreatedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(folder.createdDate),
                using: key
            ).combined!
            let encryptedLastEditedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(folder.lastEditedDate),
                using: key
            ).combined!
            let encryptedLastAccessedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(folder.lastAccessedDate),
                using: key
            ).combined!
            let encryptedId : Data = try AES.GCM.seal(
                DataConverter.uuidToData(folder.id),
                using: key
            ).combined!
            return Encrypted_DB_Folder(
                name: encryptedName,
                details: encryptedDetails,
                folders: encryptedFolders,
                entries: encryptedEntries,
                images: encryptedImages,
                videos: encryptedVideos,
                creditCards: encryptedCreditCards,
                notes: encryptedNotes,
                passkeys: encryptedPasskeys,
                iconName: encryptedIconName,
                documents: encryptedDocuments,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: encryptedId,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Entry with AES and returns an encrypted Entry
    private func encryptAES(entry : DB_Entry) throws -> Encrypted_DB_Entry {
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in entry.documents {
            encryptedDocuments.append(try encryptAES(lr: doc))
        }
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in entry.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedTitle : Data = try AES.GCM.seal(
                DataConverter.stringToData(entry.title),
                using: key
            ).combined!
            let encryptedDetails : Data = try AES.GCM.seal(
                DataConverter.stringToData(entry.details),
                using: key
            ).combined!
            let encryptedURL = try AES.GCM.seal(
                DataConverter.stringToData(entry.url?.absoluteString ?? ""),
                using: key
            ).combined!
            let encryptedIconName : Data = try AES.GCM.seal(
                DataConverter.stringToData(entry.iconName),
                using: key
            ).combined!
            let encryptedCreatedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(entry.createdDate),
                using: key
            ).combined!
            let encryptedLastEditedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(entry.lastEditedDate),
                using: key
            ).combined!
            let encryptedLastAccessedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(entry.lastAccessedDate),
                using: key
            ).combined!
            let encryptedId : Data = try AES.GCM.seal(
                DataConverter.uuidToData(entry.id),
                using: key
            ).combined!
            return Encrypted_DB_Entry(
                title: encryptedTitle,
                encryptedUsername: entry.encryptedUsername,
                encryptedPassword: entry.encryptedPassword,
                url: encryptedURL,
                details: encryptedDetails,
                iconName: encryptedIconName,
                documents: encryptedDocuments,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: encryptedId,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Image with AES and returns
    /// an encrypted Image
    private func encryptAES(image : DB_Image) throws -> Encrypted_DB_Image {
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in image.tags {
            // TODO: add tag encryption
        }
        let imageData : Data = try DataConverter.imageToData(image)
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try AES.GCM.seal(
                DataConverter.stringToData(image.name),
                using: key
            ).combined!
            let encryptedImageData : Data = try AES.GCM.seal(
                imageData,
                using: key
            ).combined!
            let encryptedQuality : Data = try AES.GCM.seal(
                DataConverter.doubleToData(image.quality),
                using: key
            ).combined!
            let encryptedCreatedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(image.createdDate),
                using: key
            ).combined!
            let encryptedLastEditedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(image.lastEditedDate),
                using: key
            ).combined!
            let encryptedLastAccessedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(image.lastAccessedDate),
                using: key
            ).combined!
            return Encrypted_DB_Image(
                name: encryptedName,
                image: encryptedImageData,
                quality: encryptedQuality,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: image.id,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Video with AES and returns
    /// an encrypted Image
    private func encryptAES(video : DB_Video) throws -> Encrypted_DB_Video {
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in video.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedVideoData : Data = try AES.GCM.seal(
                video.videoData,
                using: key
            ).combined!
            let encryptedCreatedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(video.createdDate),
                using: key
            ).combined!
            let encryptedLastEditedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(video.lastEditedDate),
                using: key
            ).combined!
            let encryptedLastAccessedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(video.lastAccessedDate),
                using: key
            ).combined!
            return Encrypted_DB_Video(
                videoData: encryptedVideoData,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: video.id,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Document with AES and returns
    /// an encrypted Document
    private func encryptAES(document : DB_Document) throws -> Encrypted_DB_Document {
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in document.tags {
            // TODO: encrypt tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedDocument : Data = try AES.GCM.seal(
                document.document,
                using: key
            ).combined!
            let encryptedType : Data = try AES.GCM.seal(
                DataConverter.stringToData(document.type),
                using: key
            ).combined!
            let encryptedName : Data = try AES.GCM.seal(
                DataConverter.stringToData(document.name),
                using: key
            ).combined!
            let encryptedCreatedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(document.createdDate),
                using: key
            ).combined!
            let encryptedLastEditedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(document.lastEditedDate),
                using: key
            ).combined!
            let encryptedLastAccessedDate : Data = try AES.GCM.seal(
                DataConverter.dateToData(document.lastAccessedDate),
                using: key
            ).combined!
            return Encrypted_DB_Document(
                document: encryptedDocument,
                type: encryptedType,
                name: encryptedName,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: document.id,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Loadable Resource with AES and returns
    /// an encrypted representation of this Loadable Resource Type
    private func encryptAES(lr : DB_LoadableResource) throws -> Encrypted_DB_LoadableResource {
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try AES.GCM.seal(
                DataConverter.stringToData(lr.name ?? ""),
                using: key
            ).combined!
            let encryptedThumbnailData : Data = try AES.GCM.seal(
                lr.thumbnailData,
                using: key
            ).combined!
            return Encrypted_DB_LoadableResource(
                id: lr.id,
                name: encryptedName,
                thumbnailData: encryptedThumbnailData
            )
        }
    }
    
    
    // START ChaChaPoly ENCRYPTION
    // MARK: CHACHAPOLY ENCRYPTION

    /// Encrypts Databases with ChaChaPoly
    /// Throws an Error if something went wrong
    private func encryptChaChaPoly(_ database : Database) throws -> EncryptedDatabase {
        var encryptedFolders : [Encrypted_DB_Folder] = []
        for folder in database.folders {
            encryptedFolders.append(try encryptChaChaPoly(folder: folder))
        }
        var encryptedEntries : [Encrypted_DB_Entry] = []
        for entry in database.entries {
            encryptedEntries.append(try encryptChaChaPoly(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_LoadableResource] = []
        for image in database.images {
            encryptedImages.append(try encryptChaChaPoly(lr: image))
        }
        var encryptedVideos : [Encrypted_DB_LoadableResource] = []
        for video in database.videos {
            encryptedVideos.append(try encryptChaChaPoly(lr: video))
        }
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in database.documents {
            encryptedDocuments.append(try encryptChaChaPoly(lr: doc))
        }
        var encryptedCreditCards : [Encrypted_DB_CreditCard] = []
        for card in database.creditCards {
            // TODO: implement card encryption
        }
        var encryptedNotes : [Encrypted_DB_Note] = []
        for note in database.notes {
            // TODO: implement notes encryption
        }
        var encryptedPasskeys : [Encrypted_DB_Passkey] = []
        for passkey in database.passkeys {
            // TODO: implement passkey encryption
        }
        let encryptedDatabase : EncryptedDatabase = EncryptedDatabase(
            decryptedName: database.name,
            decryptedDetails: database.details,
            folders: encryptedFolders,
            entries: encryptedEntries,
            images: encryptedImages,
            videos: encryptedVideos,
            creditCards: encryptedCreditCards,
            notes: encryptedNotes,
            passkeys: encryptedPasskeys,
            decryptedIconName: database.iconName,
            documents: encryptedDocuments,
            decryptedCreatedDate: database.createdDate,
            decryptedLastEditedDate: database.lastEditedDate,
            decryptedLastAccessedDate: database.lastAccessedDate,
            header: database.header,
            decryptedId: database.id
        )
        return encryptedDatabase
    }
    
    /// Encrypts the key using ChaChaPoly and returns it as encrypted Data
    private static func encryptChaChaPolyKey(
        decryptedMasterKey : SecureKeyBytes,
        dbWrappingKeyBytes : SecureKeyBytes
    ) throws -> Data {
        return try dbWrappingKeyBytes.withUnsafeBytes {
            buffer in
            try decryptedMasterKey.withUnsafeBytes {
                masterKeyBuffer in
                let encrypted : Data = try ChaChaPoly.seal(
                    Data(
                        bytesNoCopy: UnsafeMutableRawPointer(mutating: masterKeyBuffer.baseAddress!),
                        count: masterKeyBuffer.count,
                        deallocator: .none
                    ),
                    using: SymmetricKey(
                        data: Data(
                            bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
                            count: buffer.count,
                            deallocator: .none
                        )
                    )
                ).combined
                return encrypted
            }
        }
    }
    
    
    /// Encryptes the passed Folder with ChaChaPoly and returns
    /// an encrypted Folder
    private func encryptChaChaPoly(folder : DB_Folder) throws -> Encrypted_DB_Folder {
        var encryptedFolders : [Encrypted_DB_Folder] = []
        for folder in folder.folders {
            encryptedFolders.append(try encryptChaChaPoly(folder: folder))
        }
        var encryptedEntries : [Encrypted_DB_Entry] = []
        for entry in folder.entries {
            encryptedEntries.append(try encryptChaChaPoly(entry: entry))
        }
        var encryptedImages : [Encrypted_DB_LoadableResource] = []
        for image in folder.images {
            encryptedImages.append(try encryptChaChaPoly(lr: image))
        }
        var encryptedVideos : [Encrypted_DB_LoadableResource] = []
        for video in folder.videos {
            encryptedVideos.append(try encryptChaChaPoly(lr: video))
        }
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in folder.documents {
            encryptedDocuments.append(try encryptChaChaPoly(lr: doc))
        }
        var encryptedCreditCards : [Encrypted_DB_CreditCard] = []
        for card in folder.creditCards {
            // TODO: implement card encryption
        }
        var encryptedNotes : [Encrypted_DB_Note] = []
        for note in folder.notes {
            // TODO: implement notes encryption
        }
        var encryptedPasskeys : [Encrypted_DB_Passkey] = []
        for passkey in folder.passkeys {
            // TODO: implement passkey encryption
        }
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in folder.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(folder.name),
                using: key
            ).combined
            let encryptedDetails : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(folder.details),
                using: key
            ).combined
            let encryptedIconName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(folder.iconName),
                using: key
            ).combined
            let encryptedCreatedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(folder.createdDate),
                using: key
            ).combined
            let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(folder.lastEditedDate),
                using: key
            ).combined
            let encryptedLastAccessedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(folder.lastAccessedDate),
                using: key
            ).combined
            let encryptedId : Data = try ChaChaPoly.seal(
                DataConverter.uuidToData(folder.id),
                using: key
            ).combined
            return Encrypted_DB_Folder(
                name: encryptedName,
                details: encryptedDetails,
                folders: encryptedFolders,
                entries: encryptedEntries,
                images: encryptedImages,
                videos: encryptedVideos,
                creditCards: encryptedCreditCards,
                notes: encryptedNotes,
                passkeys: encryptedPasskeys,
                iconName: encryptedIconName,
                documents: encryptedDocuments,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: encryptedId,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Entry with ChaChaPoly and returns an encrypted Entry
    private func encryptChaChaPoly(entry : DB_Entry) throws -> Encrypted_DB_Entry {
        var encryptedDocuments : [Encrypted_DB_LoadableResource] = []
        for doc in entry.documents {
            encryptedDocuments.append(try encryptChaChaPoly(lr: doc))
        }
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in entry.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedTitle : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(entry.title),
                using: key
            ).combined
            let encryptedDetails : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(entry.details),
                using: key
            ).combined
            let encryptedURL = try ChaChaPoly.seal(
                DataConverter.stringToData(entry.url!.absoluteString),
                using: key
            ).combined
            let encryptedIconName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(entry.iconName),
                using: key
            ).combined
            let encryptedCreatedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(entry.createdDate),
                using: key
            ).combined
            let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(entry.lastEditedDate),
                using: key
            ).combined
            let encryptedLastAccessedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(entry.lastAccessedDate),
                using: key
            ).combined
            let encryptedId : Data = try ChaChaPoly.seal(
                DataConverter.uuidToData(entry.id),
                using: key
            ).combined
            return Encrypted_DB_Entry(
                title: encryptedTitle,
                encryptedUsername: entry.encryptedUsername,
                encryptedPassword: entry.encryptedPassword,
                url: encryptedURL,
                details: encryptedDetails,
                iconName: encryptedIconName,
                documents: encryptedDocuments,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: encryptedId,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Image with ChaChaPoly and returns
    /// an encrypted Image
    private func encryptChaChaPoly(image : DB_Image) throws -> Encrypted_DB_Image {
        let imageData : Data = try DataConverter.imageToData(image)
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in image.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(image.name),
                using: key
            ).combined
            let encryptedImageData : Data = try ChaChaPoly.seal(
                imageData,
                using: key
            ).combined
            let encryptedQuality : Data = try ChaChaPoly.seal(
                DataConverter.doubleToData(image.quality),
                using: key
            ).combined
            let encryptedCreatedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(image.createdDate),
                using: key
            ).combined
            let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(image.lastEditedDate),
                using: key
            ).combined
            let encryptedLastAccessedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(image.lastAccessedDate),
                using: key
            ).combined
            return Encrypted_DB_Image(
                name: encryptedName,
                image: encryptedImageData,
                quality: encryptedQuality,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: image.id,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Video with ChaChaPoly and returns
    /// an encrypted Image
    private func encryptChaChaPoly(video : DB_Video) throws -> Encrypted_DB_Video {
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in video.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedVideoData : Data = try ChaChaPoly.seal(
                video.videoData,
                using: key
            ).combined
            let encryptedCreatedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(video.createdDate),
                using: key
            ).combined
            let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(video.lastEditedDate),
                using: key
            ).combined
            let encryptedLastAccessedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(video.lastAccessedDate),
                using: key
            ).combined
            return Encrypted_DB_Video(
                videoData: encryptedVideoData,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: video.id,
                tags: encryptedTags
            )

        }
    }

    /// Encrypts the passed Document with ChaChaPoly and returns
    /// an encrypted Document
    private func encryptChaChaPoly(document : DB_Document) throws -> Encrypted_DB_Document {
        var encryptedTags : [Encrypted_DB_Tag] = []
        for tag in document.tags {
            // TODO: implement tag encryption
        }
        return try keyVault.withKey {
            key in
            let encryptedDocument : Data = try ChaChaPoly.seal(
                document.document,
                using: key
            ).combined
            let encryptedType : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(document.type),
                using: key
            ).combined
            let encryptedName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(document.name),
                using: key
            ).combined
            let encryptedCreatedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(document.createdDate),
                using: key
            ).combined
            let encryptedLastEditedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(document.lastEditedDate),
                using: key
            ).combined
            let encryptedLastAccessedDate : Data = try ChaChaPoly.seal(
                DataConverter.dateToData(document.lastAccessedDate),
                using: key
            ).combined
            return Encrypted_DB_Document(
                document: encryptedDocument,
                type: encryptedType,
                name: encryptedName,
                createdDate: encryptedCreatedDate,
                lastEditedDate: encryptedLastEditedDate,
                lastAccessedDate: encryptedLastAccessedDate,
                id: document.id,
                tags: encryptedTags
            )
        }
    }
    
    /// Encrypts the passed Loadable Resource with ChaChaPoly and returns
    /// an encrypted representation of this Loadable Resource Type
    private func encryptChaChaPoly(lr : DB_LoadableResource) throws -> Encrypted_DB_LoadableResource {
        return try keyVault.withKey {
            key in
            let encryptedName : Data = try ChaChaPoly.seal(
                DataConverter.stringToData(lr.name ?? ""),
                using: key
            ).combined
            let encryptedThumbnailData : Data = try ChaChaPoly.seal(
                lr.thumbnailData,
                using: key
            ).combined
            return Encrypted_DB_LoadableResource(
                id: lr.id,
                name: encryptedName,
                thumbnailData: encryptedThumbnailData
            )

        }
    }
}
