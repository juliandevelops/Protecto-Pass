//
//  Database.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import CryptoKit
import Foundation
import UIKit

/// The Top Level class for all databases.
/// Because the encrypted and decrypted Database have something in common,
/// this class puts these common things together
internal class GeneralDatabase<
    FolderType,
    EntryType,
    LoadableResourceType,
    CreditCardType,
    NotesType,
    PasskeyType,
> : DB_ME_DataStructure<
    String,
    Date,
    FolderType,
    EntryType,
    LoadableResourceType,
    CreditCardType,
    NotesType,
    PasskeyType,
    UUID,
    DB_Tag // Currently the DB_Tag type is used, altough databases cannot have tags. This is done so the same view can be used for databases and folders. NEVER ADD TAGS TO DATABASES AS THEY WONT BE ENCRYPTED.
> {

    /// The Header for this Database,
    /// The header contains all information like keys, key algorithm parameters,
    /// versioning and more
    internal let header : DB_Header


    internal init(
        decryptedName : String,
        decryptedDetails: String,
        folders : [FolderType],
        entries : [EntryType],
        images : [LoadableResourceType],
        videos : [LoadableResourceType],
        creditCards : [CreditCardType],
        notes: [NotesType],
        passkeys: [PasskeyType],
        decryptedIconName : String,
        documents : [LoadableResourceType],
        decryptedCreatedDate : Date,
        decryptedLastEditedDate : Date,
        decryptedLastAccessedDate : Date,
        header : DB_Header,
        decryptedId: UUID
    ) {
        self.header = header
        super.init(
            name: decryptedName,
            details: decryptedDetails,
            folders: folders,
            entries: entries,
            images: images,
            videos: videos,
            creditCards: creditCards,
            notes: notes,
            passkeys: passkeys,
            iconName: decryptedIconName,
            documents: documents,
            createdDate: decryptedCreatedDate,
            lastEditedDate : decryptedLastEditedDate,
            lastAccessedDate: decryptedLastAccessedDate,
            id: decryptedId,
            tags: [] // Empty tag array as explained above. Tag array is required though due to inheritance
        )
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<
    DB_Folder,
    DB_Entry,
    DB_LoadableResource,
    DB_CreditCard,
    DB_Note,
    DB_Passkey
>, DecryptedDataStructure {
    
    static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.name == rhs.name &&
        lhs.details == rhs.details &&
        lhs.iconName == rhs.iconName &&
        lhs.folders == rhs.folders &&
        lhs.entries == rhs.entries &&
        lhs.createdDate == rhs.createdDate &&
        lhs.lastEditedDate == rhs.lastEditedDate &&
        lhs.header == rhs.header &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
        hasher.combine(name)
        hasher.combine(details)
        hasher.combine(folders)
        hasher.combine(entries)
        hasher.combine(iconName)
        hasher.combine(id)
    }

    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(
        decryptedName: "Preview Database",
        decryptedDetails: "This is a Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        creditCards: [],
        notes: [],
        passkeys: [],
        decryptedIconName: "externaldrive",
        documents: [],
        decryptedCreatedDate: Date.now,
        decryptedLastEditedDate: Date.now,
        decryptedLastAccessedDate: Date.now,
        header: DB_Header.previewHeader,
        decryptedId: UUID()
    )
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<
    Encrypted_DB_Folder,
    Encrypted_DB_Entry,
    Encrypted_DB_LoadableResource,
    Encrypted_DB_CreditCard,
    Encrypted_DB_Note,
    Encrypted_DB_Passkey
>, EncryptedDataStructure {

    private enum DatabaseCodingKeys: CodingKey {
        case name
        case details
        case folders
        case entries
        case images
        case videos
        case creditCards
        case notes
        case passkeys
        case iconName
        case documents
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case header
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DatabaseCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(details, forKey: .details)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(images, forKey: .images)
        try container.encode(videos, forKey: .videos)
        try container.encode(creditCards, forKey: .creditCards)
        try container.encode(notes, forKey: .notes)
        try container.encode(passkeys, forKey: .passkeys)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(header, forKey: .header)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DatabaseCodingKeys.self)
        self.init(
            decryptedName: try container.decode(String.self, forKey: .name),
            decryptedDetails: try container.decode(String.self, forKey: .details),
            folders: try container.decode([Encrypted_DB_Folder].self, forKey: .folders),
            entries: try container.decode([Encrypted_DB_Entry].self, forKey: .entries),
            images: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .images),
            videos: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .videos),
            creditCards: try container.decode([Encrypted_DB_CreditCard].self, forKey: .creditCards),
            notes: try container.decode([Encrypted_DB_Note].self, forKey: .notes),
            passkeys: try container.decode([Encrypted_DB_Passkey].self, forKey: .passkeys),
            decryptedIconName: try container.decode(String.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .documents),
            decryptedCreatedDate: try container.decode(Date.self, forKey: .createdDate),
            decryptedLastEditedDate: try container.decode(Date.self, forKey: .lastEditedDate),
            decryptedLastAccessedDate: try container.decode(Date.self, forKey: .lastAccessedDate),
            header: try container.decode(DB_Header.self, forKey: .header),
            decryptedId: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Database) throws {
        var localFolders : [Encrypted_DB_Folder] = []
        for folder in coreData.folders! {
            localFolders.append(try Encrypted_DB_Folder(from: folder as! CD_Folder))
        }
        var localEntries : [Encrypted_DB_Entry] = []
        for entry in coreData.entries! {
            localEntries.append(try Encrypted_DB_Entry(from: entry as! CD_Entry))
        }
        var localDocuments : [Encrypted_DB_LoadableResource] = []
        for document in coreData.documents! {
            localDocuments.append(Encrypted_DB_LoadableResource(from: document as! CD_LoadableResource))
        }
        var localImages : [Encrypted_DB_LoadableResource] = []
        for image in coreData.images! {
            localImages.append(Encrypted_DB_LoadableResource(from: image as! CD_LoadableResource))
        }
        var localVideos : [Encrypted_DB_LoadableResource] = []
        for video in coreData.videos! {
            localVideos.append(Encrypted_DB_LoadableResource(from: video as! CD_LoadableResource))
        }
        var localCreditCards : [Encrypted_DB_CreditCard] = []
        for creditCard in coreData.creditCards! {
            localCreditCards.append(try Encrypted_DB_CreditCard(from: creditCard as! CD_CreditCard))
        }
        var localNotes : [Encrypted_DB_Note] = []
        for note in coreData.notes! {
            localNotes.append(try Encrypted_DB_Note(from: note as! CD_Note))
        }
        var localPasskeys : [Encrypted_DB_Passkey] = []
        for passkey in coreData.passkeys! {
//            localPasskeys.append(Encrypted_DB_Passkey(passkey as! CD_Passkey))
        }
        self.init(
            decryptedName: DataConverter.dataToString(coreData.name!),
            decryptedDetails: DataConverter.dataToString(coreData.details),
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            videos: localVideos,
            creditCards: localCreditCards,
            notes: localNotes,
            passkeys: localPasskeys,
            decryptedIconName: DataConverter.dataToString(coreData.iconName!),
            documents: localDocuments,
            decryptedCreatedDate: try DataConverter.dataToDate(coreData.createdDate!),
            decryptedLastEditedDate: try DataConverter.dataToDate(coreData.lastEditedDate!),
            decryptedLastAccessedDate: try DataConverter.dataToDate(coreData.lastAccessedDate!),
            header: try DB_Header(from: coreData.header!),
            decryptedId: DataConverter.dataToUUID(coreData.uuid!)
        )
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : EncryptedDatabase = EncryptedDatabase(
        decryptedName: "Preview Database",
        decryptedDetails: "This is an encrypted Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        creditCards: [],
        notes: [],
        passkeys: [],
        decryptedIconName: "externaldrive",
        documents: [],
        decryptedCreatedDate: Date.now,
        decryptedLastEditedDate: Date.now,
        decryptedLastAccessedDate: Date.now,
        header: DB_Header.previewHeader,
        decryptedId: UUID()
    )
}
