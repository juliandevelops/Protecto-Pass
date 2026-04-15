//
//  VaultSession.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 06.03.26.
//

import Combine
import CoreData
import CryptoKit
import Foundation

/// A single vault session with the decrypted master key
/// as well as
internal class VaultSession : ObservableObject {

    /// The current database vault for this session
    @Published internal private(set) var database : Database

    /// The current Encrypter instance for this session
    @Published private var encrypter : Encrypter

    /// The current decrypter vault for this session
    @Published private var decrypter : Decrypter


    internal init(
        userPassword : SecureKeyBytes,
        encryptedDatabase : EncryptedDatabase
    ) throws {
        // Derive Key
        let dbWrappingKeyBytes : SecureKeyBytes = try Decrypter.deriveKey(userPassword, header: encryptedDatabase.header)
        let masterKeyDataBytes : SecureKeyBytes = try Decrypter.decryptMasterKey(
            header: encryptedDatabase.header,
            dbWrappingKeyBytes: dbWrappingKeyBytes
        )
        // Create vault
        let keyVault : SessionKeyVault = SessionKeyVault(masterKeyDataBytes: masterKeyDataBytes)
        self.encrypter = Encrypter(keyVault: keyVault)
        self.decrypter = Decrypter(keyVault: keyVault)

        // Zero out data
        dbWrappingKeyBytes.zeroOut()
        // masterKeyDataBytes is zeroed out in keyVault init

        // Decrypt Database
        self.database = Database.previewDB // Preview database is added here so all values are stored before decrypter can be used
        self.database = try decrypter.decryptDatabase(
                encryptedDatabase,
                encryption: encryptedDatabase.header.encryption
        )
    }

    internal init(
        userPassword : SecureKeyBytes,
        newDatabase : Database
    ) throws {
        // Derive Key
        let dbWrappingKeyBytes : SecureKeyBytes = try Decrypter.deriveKey(userPassword, header: newDatabase.header)
        // Create new masterkey
        let masterKey : SecureKeyBytes = try SecureKeyBytes.generateNewSymmetricKey()
        // Create vault
        let keyVault : SessionKeyVault = SessionKeyVault(masterKeyDataBytes: masterKey)
        self.encrypter = Encrypter(keyVault: keyVault)
        self.decrypter = Decrypter(keyVault: keyVault)
        // TODO: encrypt masterKey with dbWrappingKey and store into header
        // Zero out data
//        dbWrappingKeyBytes.zeroOut()
        self.database = newDatabase
    }

    // MARK: CRYPTO FUNCTIONS

    internal func decryptSensitiveContent(entry : inout DB_Entry) throws -> Void {
        // TODO: implement decrypion of sensitive entry content
    }

    internal func zeroOutSensitiveContent(entry : inout DB_Entry) throws -> Void {
        // TODO: implement zero out of sensitive entry content
    }

    internal func decryptImage(_ image : Encrypted_DB_Image) throws -> DB_Image {
        return try decrypter.decryptImage(
            image,
            encryption: database.header.encryption
        )
    }

    internal func decryptVideo(_ video : Encrypted_DB_Video) throws -> DB_Video {
        return try decrypter.decryptVideo(
            video,
            encryption: database.header.encryption
        )
    }

    internal func decryptDocument(_ document : Encrypted_DB_Document) throws -> DB_Document {
        return try decrypter.decryptDocument(
            document,
            encryption: database.header.encryption
        )
    }

//    internal func encryptImage(_ image : Encrypted_DB_Image) throws -> Encrypted_DB_Image {
//        return try encrypter.encryptImage(
//            image,
//            encryption: database.header.encryption
//        )
//    }

//    internal func encryptVideo(_ video : Encrypted_DB_Video) throws -> Encrypted_DB_Video {
//        return try encrypter.encryptVideo(
//            video,
//            encryption: database.header.encryption
//        )
//    }

//    internal func encryptDocument(_ doc : Encrypted_DB_Document) throws -> Encrypted_DB_Document {
//        return try encrypter.encryptDocument(
//            doc,
//            encryption: database.header.encryption
//        )
//    }

    // MARK: EDIT DATABASE FUNCTIONS

    /* ADD NEW ELEMENTS */

    internal func addEntry(_ entry : DB_Entry, context : NSManagedObjectContext) -> Void {

    }

    internal func addFolder(_ folder : DB_Folder, context : NSManagedObjectContext) -> Void {

    }

    internal func addImage(_ image : DB_Image, context : NSManagedObjectContext) -> Void {

    }

    internal func addVideo(_ video : DB_Video, context : NSManagedObjectContext) -> Void {

    }

    internal func addDocument(_ doc : DB_Document, context : NSManagedObjectContext) -> Void {

    }

    /* DELETE ELEMENT */

    // TODO: can this be replaced by a single delete(id : UUID) function?
    internal func deleteEntry(id: UUID, context : NSManagedObjectContext) -> Void {

    }

    internal func deleteFolder(id: UUID, context : NSManagedObjectContext) -> Void {

    }

    internal func deleteImage(id: UUID, context : NSManagedObjectContext) -> Void {

    }

    internal func deleteVideo(id: UUID, context : NSManagedObjectContext) -> Void {

    }

    /* ACCESS ENCRYPTED CONTENT */

    private func getEncryptedDatabase() throws -> EncryptedDatabase {
        return try encrypter.encryptDatabase(database, encryption: database.header.encryption)
    }

    /* STORE DATABASE */

    internal func store(context : NSManagedObjectContext?) throws {
        return try Storage.storeDatabase(getEncryptedDatabase(), context: context)
    }

    deinit {
        // TODO: zero out encrypter and decrypter
    }
}
