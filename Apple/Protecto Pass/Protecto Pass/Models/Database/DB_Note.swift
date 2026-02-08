//
//  DB_Note.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.02.26.
//

import Foundation

/// A general secure note in this safe
///
/// ## Params
/// C: Content
/// DE: Date
/// DA: Icon Name Data
/// DO: Document link
internal class DB_GeneralNote<C, DE, DA, DO> : DB_NativeType<DE, DA, DO> {

    internal var content : C

    internal init(content: C) {
        self.content = content
    }
}

internal final class DB_Note : DB_GeneralNote<String, Date, String, DB_LoadableResource>, DecryptedDataStructure {
    static func == (lhs: DB_Note, rhs: DB_Note) -> Bool {
        return lhs.content == rhs.content &&
        lhs.iconName == rhs.iconName &&
        lhs.created == rhs.created &&
        lhs.documents == rhs.documents &&
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(created)
        hasher.combine(content)
    }
}

internal final class Encrypted_DB_Note : DB_GeneralNote<Data, Data, Data, Encrypted_DB_LoadableResource>, EncryptedDataStructure {

    private enum NoteCodingKeys : CodingKey {
        case id
        case created
        case lastEdited
        case documents
        case iconName
        case content
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: NoteCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(documents, forKey: .documents)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(content, forKey: .content)
    }

    // TODO: work on init. Is it necessary to encode id etc. here? Where does it come from?
    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: NoteCodingKeys.self)
        self.init(
            content: try container.decode(Data.self, forKey: .content)
        )
    }
}
