//
//  DB_Note.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.02.26.
//

import Foundation

/// A general secure note in this safe
internal class DB_GeneralNote<ContentType, DateType, IDType, TagType> : DatabaseContent<DateType, IDType, TagType> {


    internal var content : ContentType

    internal init(
        content: ContentType,
        createdDate: DateType,
        lastEditedDate: DateType,
        lastAccessedDate: DateType,
        id : IDType,
        tags: [TagType]
    ) {
        self.content = content
        super.init(
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}

/// A decrypted note in this app
internal final class DB_Note : DB_GeneralNote<String, Date, UUID, DB_Tag>, DecryptedDataStructure {
    static func == (lhs: DB_Note, rhs: DB_Note) -> Bool {
        return lhs.content == rhs.content &&
        lhs.createdDate == rhs.createdDate &&
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(createdDate)
        hasher.combine(content)
    }
}

internal final class Encrypted_DB_Note : DB_GeneralNote<Data, Data, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    private enum NoteCodingKeys : CodingKey {
        case content
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: NoteCodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }


    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: NoteCodingKeys.self)
        self.init(
            content: try container.decode(Data.self, forKey: .content),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(Data.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }

    internal convenience init(from coreData : CD_Note) throws {
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            content: coreData.content!,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: coreData.uuid!,
            tags: localTags
        )
    }
}
