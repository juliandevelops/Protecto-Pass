//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import SwiftUI

internal class GeneralEntry<DA, U, DE, DO> : NativeType<DE, DA, DO> {
    
    /// The Title of this Entry
    internal var title : DA
    
    /// The Username connected to this Entry
    internal var username : DA
    
    /// The Password stored with this Entry
    internal var password : DA
    
    /// The URL this Entry is connected to
    internal var url : U
    
    /// Some notes storing whatever
    /// the User wants to add to this Entry
    internal var notes : DA
    
    internal init(
        title: DA,
        username: DA,
        password: DA,
        url: U,
        notes: DA,
        iconName : DA,
        documents : [DO],
        created : DE,
        lastEdited : DE,
        id : UUID
    ) {
        self.title = title
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
        super.init(
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            id: id
        )
    }
}

/// The Struct representing an Entry
/// while this App is running
internal final class Entry : GeneralEntry<String, URL?, Date, LoadableResource>, DecryptedDataStructure {
    
    internal static let previewEntry : Entry = Entry(
        title: "Test Entry",
        username: "user",
        password: "testPassword",
        url: URL(string: "https://github.com/V3Sofficial/Protecto-Pass", encodingInvalidCharacters: false),
        notes: "This is a preview Entry, only to use in previews and tests",
        iconName: "doc",
        documents: [],
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.title == rhs.title &&
        lhs.username == rhs.username &&
        lhs.password == rhs.password &&
        lhs.url == rhs.url &&
        lhs.notes == rhs.notes &&
        lhs.created == rhs.created &&
        lhs.lastEdited == rhs.lastEdited &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(title)
        hasher.combine(username)
        hasher.combine(password)
        hasher.combine(url)
        hasher.combine(notes)
    }
}

/// The Encrypted Entry storing all the
/// Data of an Entry secure and encrypted
internal final class EncryptedEntry : GeneralEntry<Data, Data, Data, EncryptedLoadableResource>, EncryptedDataStructure {
    
    override internal init(
        title : Data,
        username : Data,
        password : Data,
        url : Data,
        notes : Data,
        iconName : Data,
        documents : [EncryptedLoadableResource],
        created : Data,
        lastEdited : Data,
        id : UUID
    ) {
        super.init(
            title: title,
            username: username,
            password: password,
            url: url,
            notes: notes,
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            id: id
        )
    }
    
    private enum EntryCodingKeys: CodingKey {
        case title
        case username
        case password
        case url
        case notes
        case iconName
        case documents
        case created
        case lastEdited
        case id
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EntryCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(url, forKey: .url)
        try container.encode(notes, forKey: .notes)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(id, forKey: .id)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: EntryCodingKeys.self)
        self.init(
            title: try container.decode(Data.self, forKey: .title),
            username: try container.decode(Data.self, forKey: .username),
            password: try container.decode(Data.self, forKey: .password),
            url: try container.decode(Data.self, forKey: .url),
            notes: try container.decode(Data.self, forKey: .notes),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([EncryptedLoadableResource].self, forKey: .documents),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal init(from coreData : CD_Entry) {
        var localDocuments : [EncryptedLoadableResource] = []
        for document in coreData.documents! {
            localDocuments.append(EncryptedLoadableResource(from: document as! CD_LoadableResource))
        }
        super.init(
            title: coreData.title!,
            username: coreData.username!,
            password: coreData.password!,
            url: coreData.url!,
            notes: coreData.notes!,
            iconName: coreData.iconName!,
            documents: localDocuments,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!,
            id: coreData.uuid!
        )
    }
}
