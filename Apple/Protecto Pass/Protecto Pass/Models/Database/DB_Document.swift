//
//  DB_Document.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Generalised Document class for any document stored in this app.
/// Documents do not include database internal types such as `Entries` or `Folders`.
/// Documents can be any file stored on the users device.
///
/// All data that are loaded as external resources (such as documents) cannot have encrypted IDs as they must be identifiable
/// by the reference to them.
/// That's why all documents have an id of type UUID
internal class GeneralDocument<DataType, DateType, TagType> : DatabaseContent<DateType, UUID, TagType> {

    /// Document Data read from this Document.
    /// This is the content in binary representation
    internal let document : Data
    
    /// The Type or extension of this Document.
    /// Also named filetype or file extension
    internal let type : DataType

    /// The name or title of this document as it is named on the file system
    internal let name : DataType


    internal init(
        document: Data,
        type: DataType,
        name : DataType,
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : UUID,
        tags : [TagType]
    ) {
        self.document = document
        self.type = type
        self.name = name
        super.init(
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}


/// Decrypted Document to use in the decrypted Database.
/// This Document contains all information in plaintext
internal final class DB_Document : GeneralDocument<String, Date, DB_Tag>, DecryptedDataStructure {

    /// Whether or not this document is a plain text document
    // TODO: maybe add xml, json etc. here?
    internal var isText : Bool {
        let textfileTypeEnding : [String] = ["txt", "rtf", "md"]
        return textfileTypeEnding.contains(type)
    }

    /// Whether or not this document contains formatted Text.
    /// Some types of formatted text can be viewed directly inside the app
    internal var isFormattedText : Bool { type == "md" || type == "rtf" }

    /// Whether or not this document is a pdf
    internal var isPDF : Bool { type == "pdf" }

    /// Returns true if this document can be viewed directly inside this app
    internal func canBeViewed() -> Bool { isText || isPDF }


    internal static func == (lhs: DB_Document, rhs: DB_Document) -> Bool {
        return lhs.document == rhs.document &&
        lhs.type == rhs.type &&
        lhs.id == rhs.id &&
        rhs.name == lhs.name &&
        lhs.tags == rhs.tags
    }

    internal func hash(into hasher: inout Hasher) {
        hasher.combine(document)
        hasher.combine(type)
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(tags)
    }
}

/// Encrypted Document type storing the encrypted values
internal final class Encrypted_DB_Document : GeneralDocument<Data, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    internal convenience init(from coreData : CD_Document) throws {
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            document: coreData.documentData!,
            type: coreData.type!,
            name: coreData.name!,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: DataConverter.dataToUUID(coreData.uuid!), // id must be stored as data in core data to support encryption. However, this is not encrypted (see documentation at top of this file), so this can be converted directly
            tags: localTags
        )
    }

    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DB_DocumentCodingKeys.self)
        self.init(
            document: try container.decode(Data.self, forKey: .document),
            type: try container.decode(Data.self, forKey: .type),
            name: try container.decode(Data.self, forKey: .name),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(UUID.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }

    /// Coding Keys to encode or decode this document
    private enum DB_DocumentCodingKeys: CodingKey {
        case document
        case type
        case name
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DB_DocumentCodingKeys.self)
        try container.encode(document, forKey: .document)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
}
