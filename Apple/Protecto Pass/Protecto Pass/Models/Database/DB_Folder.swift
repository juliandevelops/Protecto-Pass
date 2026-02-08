//
//  Folder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import UIKit

internal class GeneralFolder<DA, DE, F, E, L> : ME_DataStructure<DA, DE, F, E, L> {}

/// The Folder Object that is used when the App is running
internal final class Folder : GeneralFolder<String, Date, Folder, Entry, LoadableResource>, DecryptedDataStructure {
    
    /// An static preview folder with sample data to use in Previews and Tests
    internal static let previewFolder : Folder = Folder(
        name: "Private",
        description: "This is an preview Folder only to use in previews and tests",
        folders: [],
        entries: [],
        images: [],
        videos: [],
        iconName: "folder",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(id)
    }
}

/// The Object holding an encrypted Folder
internal final class EncryptedFolder : GeneralFolder<Data, Data, EncryptedFolder, EncryptedEntry, EncryptedLoadableResource>, EncryptedDataStructure {
    
    override internal init(
        name: Data,
        description: Data,
        folders: [EncryptedFolder],
        entries : [EncryptedEntry],
        images: [EncryptedLoadableResource],
        videos: [EncryptedLoadableResource],
        iconName : Data,
        documents : [EncryptedLoadableResource],
        created : Data,
        lastEdited : Data,
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
            id: id
        )
    }
    
    private enum FolderCodingKeys: CodingKey {
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
        case id
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FolderCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(folders, forKey: .folders)
        try container.encode(entries, forKey: .entries)
        try container.encode(images, forKey: .images)
        try container.encode(videos, forKey: .videos)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(id, forKey: .id)
    }
    
    internal  convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: FolderCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            description: try container.decode(Data.self, forKey: .description),
            folders: try container.decode([EncryptedFolder].self, forKey: .folders),
            entries: try container.decode([EncryptedEntry].self, forKey: .entries),
            images: try container.decode([EncryptedLoadableResource].self, forKey: .images),
            videos: try container.decode([EncryptedLoadableResource].self, forKey: .videos),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([EncryptedLoadableResource].self, forKey: .documents),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Folder) {
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
            name: coreData.name!,
            description: coreData.dataDescription!,
            folders: localFolders,
            entries: localEntries,
            images: localImages,
            videos: localVideos,
            iconName: coreData.iconName!,
            documents: localDocuments,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!,
            id: coreData.uuid!
        )
    }
}
