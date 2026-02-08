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
///
/// ## Params
/// F: Folder identifier
/// E: Entry Identifier
/// LR: Loadable Ressource identifier -> images, videos and documents
internal class GeneralDatabase<F, E, LR> : ME_DataStructure<String, Date, F, E, LR>, Identifiable {

    /// The Header for this Database
    internal let header : DB_Header
    
    internal init(
        name : String,
        description : String,
        folders : [F],
        entries : [E],
        images : [LR],
        videos : [LR],
        iconName : String,
        documents : [LR],
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        id: UUID
    ) {
        self.header = header
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            images: images,
            videos: videos,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited : lastEdited,
            id: id
        )
    }
}

/// The Database Object that is used when the App is running
internal final class Database : GeneralDatabase<DB_Folder, DB_Entry, DB_LoadableResource>, DecryptedDataStructure {

    /// The Password to decrypt this Database with
    internal let key : SymmetricKey

    internal init(
        name : String,
        description : String,
        folders : [DB_Folder],
        entries : [DB_Entry],
        images : [DB_LoadableResource],
        videos : [DB_LoadableResource],
        iconName : String,
        documents : [DB_LoadableResource],
        created : Date,
        lastEdited : Date,
        header : DB_Header,
        key : SymmetricKey,
        id: UUID
    ) {
        self.key = key
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            images: images,
            videos: videos,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            header: header,
            id: id
        )
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : Database = Database(
        name: "Preview Database",
        description: "This is a Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        iconName: "externaldrive",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header.previewHeader,
        key: SymmetricKey(size: .bits256),
        id: UUID()
    )
    
    static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.iconName == rhs.iconName &&
        lhs.folders == rhs.folders &&
        lhs.entries == rhs.entries &&
        lhs.created == rhs.created &&
        lhs.lastEdited == rhs.lastEdited &&
        lhs.header == rhs.header &&
        lhs.key == rhs.key &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(folders)
        hasher.combine(entries)
        hasher.combine(iconName)
        hasher.combine(id)
    }
}

/// The object storing an encrypted Database
internal final class EncryptedDatabase : GeneralDatabase<DB_EncryptedFolder, DB_EncryptedEntry, DB_EncryptedLoadableResource>, EncryptedDataStructure {

    override internal init(
        name: String,
        description: String,
        folders: [DB_EncryptedFolder],
        entries: [DB_EncryptedEntry],
        images : [DB_EncryptedLoadableResource],
        videos : [DB_EncryptedLoadableResource],
        iconName: String,
        documents : [DB_EncryptedLoadableResource],
        created : Date,
        lastEdited : Date,
        header: DB_Header,
        id: UUID
    ) {
        super.init(
            name: name,
            description: description,
            folders: folders,
            entries: entries,
            images: images,
            videos: videos,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            header: header,
            id: id
        )
    }
    
    private enum DatabaseCodingKeys: CodingKey {
        case name
        case description
        case folders
        case entries
        case images
        case videos
        case iconName
        case documents
        case created
        case lastEdited
        case header
        case allowBiometrics
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DatabaseCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(images, forKey: .images)
        try container.encode(videos, forKey: .videos)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(header, forKey: .header)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DatabaseCodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            description: try container.decode(String.self, forKey: .description),
            folders: try container.decode([EncryptedFolder].self, forKey: .folders),
            entries: try container.decode([EncryptedEntry].self, forKey: .entries),
            images: try container.decode([EncryptedLoadableResource].self, forKey: .images),
            videos: try container.decode([EncryptedLoadableResource].self, forKey: .videos),
            iconName: try container.decode(String.self, forKey: .iconName),
            documents: try container.decode([EncryptedLoadableResource].self, forKey: .documents),
            created: try container.decode(Date.self, forKey: .created),
            lastEdited: try container.decode(Date.self, forKey: .lastEdited),
            header: try container.decode(DB_Header.self, forKey: .header),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Database) throws {
        var localFolders : [EncryptedFolder] = []
        for folder in coreData.folders! {
            localFolders.append(EncryptedFolder(from: folder as! CD_Folder))
        }
        var localEntries : [EncryptedEntry] = []
        for entry in coreData.entries! {
            localEntries.append(EncryptedEntry(from: entry as! CD_Entry))
        }
        var localDocuments : [EncryptedLoadableResource] = []
        for document in coreData.documents! {
            localDocuments.append(EncryptedLoadableResource(from: document as! CD_LoadableResource))
        }
        var localImages : [EncryptedLoadableResource] = []
        for image in coreData.images! {
            localImages.append(EncryptedLoadableResource(from: image as! CD_LoadableResource))
        }
        var localVideos : [EncryptedLoadableResource] = []
        for video in coreData.videos! {
            localVideos.append(EncryptedLoadableResource(from: video as! CD_LoadableResource))
        }
        self.init(
            name: DataConverter.dataToString(coreData.name!),
            description: DataConverter.dataToString(coreData.dataDescription),
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            videos: localVideos,
            iconName: DataConverter.dataToString(coreData.iconName!),
            documents: localDocuments,
            created: try DataConverter.dataToDate(coreData.created!),
            lastEdited: try DataConverter.dataToDate(coreData.lastEdited!),
            header: DB_Header(from: coreData.header!),
            id: coreData.uuid!
        )
    }
    
    /// The Preview Database to use in Previews or Tests
    internal static let previewDB : EncryptedDatabase = EncryptedDatabase(
        name: "Preview Database",
        description: "This is an encrypted Preview Database used in Tests and Previews",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        iconName: "externaldrive",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        header: DB_Header.previewHeader,
        id: UUID()
    )
}
