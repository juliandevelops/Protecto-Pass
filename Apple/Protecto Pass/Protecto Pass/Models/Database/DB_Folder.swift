//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import UIKit

/// The general class for a folder inside this app.
/// A folder is just a ME\_DataStructure with another name, and implementations below.
/// The general folder is mapped directly to the ME\_DataStructure
typealias General_DB_Folder = DB_ME_DataStructure

/// The Folder Object that is used when the App is running.
/// This contains all items in a decrypted state.
internal final class DB_Folder : General_DB_Folder<
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
>, DecryptedDataStructure {
    
    static func == (lhs: DB_Folder, rhs: DB_Folder) -> Bool {
        return lhs.name == rhs.name && lhs.details == rhs.details && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(createdDate)
        hasher.combine(lastEditedDate)
        hasher.combine(name)
        hasher.combine(details)
        hasher.combine(id)
    }


    /// An static preview folder with sample data to use in Previews and Tests
    internal static let previewFolder : DB_Folder = DB_Folder(
        name: "Private",
        details: "This is an preview Folder only to use in previews and tests",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        creditCards: [],
        notes: [],
        passkeys: [],
        iconName: "folder",
        documents: [],
        createdDate: Date.now,
        lastEditedDate: Date.now,
        lastAccessedDate: Date.now,
        id: UUID(),
        tags: []
    )
}

/// The Object representing an encrypted Folder
internal final class Encrypted_DB_Folder : General_DB_Folder<
    Data,
    Data,
    Encrypted_DB_Folder,
    Encrypted_DB_Entry,
    Encrypted_DB_LoadableResource,
    Encrypted_DB_CreditCard,
    Encrypted_DB_Note,
    Encrypted_DB_Passkey,
    Data,
    Encrypted_DB_Tag
>, EncryptedDataStructure {
    
    private enum FolderCodingKeys: CodingKey {
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
        case id
        case tags
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FolderCodingKeys.self)
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
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
    
    internal  convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: FolderCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            details: try container.decode(Data.self, forKey: .details),
            folders: try container.decode([Encrypted_DB_Folder].self, forKey: .folders),
            entries: try container.decode([Encrypted_DB_Entry].self, forKey: .entries),
            images: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .images),
            videos: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .videos),
            creditCards: try container.decode([Encrypted_DB_CreditCard].self, forKey: .creditCards),
            notes: try container.decode([Encrypted_DB_Note].self, forKey: .notes),
            passkeys: try container.decode([Encrypted_DB_Passkey].self, forKey: .passkeys),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .documents),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(Data.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }
    
    internal convenience init(from coreData : CD_Folder) throws {
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
//            localPasskeys.append(Encrypted_DB_Passkey(from: passkey as! CD_Passkey))
        }
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            name: coreData.name!,
            details: coreData.details!,
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            videos: localVideos,
            creditCards: localCreditCards,
            notes: localNotes,
            passkeys: localPasskeys,
            iconName: coreData.iconName!,
            documents: localDocuments,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: coreData.uuid!,
            tags: localTags
        )
    }
}
