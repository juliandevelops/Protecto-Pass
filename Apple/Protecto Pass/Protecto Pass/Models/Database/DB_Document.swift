//
//  DB_Document.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation

/// Generalised Document class
internal class GeneralDocument<T, De> : DatabaseContent<De> {
    
    /// Document Data read from this Document
    internal let document : Data
    
    /// The Type or extension of this Document
    internal let type : T
    
    internal let name : T
    
    internal init(
        document: Data,
        type: T,
        name : T,
        created : De,
        lastEdited : De,
        id : UUID
    ) {
        self.document = document
        self.type = type
        self.name = name
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}


/// Decrypted Document to use in the decrypted Database
internal final class DB_Document : GeneralDocument<String, Date>, DecryptedDataStructure {
    
    internal static func == (lhs: DB_Document, rhs: DB_Document) -> Bool {
        return lhs.document == rhs.document && lhs.type == rhs.type && lhs.id == rhs.id && rhs.name == lhs.name
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(document)
        hasher.combine(type)
        hasher.combine(id)
        hasher.combine(name)
    }
    
    internal func isText() -> Bool {
        let textfileTypeEnding : [String] = ["txt", "rtf", "md"]
        return textfileTypeEnding.contains(type)
    }
    
    internal func isFormattedText() -> Bool {
        return type == "md" || type == "rtf"
    }
    
    internal func isPDF() -> Bool {
        return type == "pdf"
    }
    
    /// Returns true if this document can be viewed directly inside this app
    internal func canBeViewed() -> Bool {
        return isText() || isPDF()
    }
}

/// Encrypted Document type storing the encrypted values
internal final class Encrypted_DB_Document : GeneralDocument<Data, Data>, EncryptedDataStructure {
    
    override internal init(
        document: Data,
        type: Data,
        name: Data,
        created : Data,
        lastEdited : Data,
        id : UUID
    ) {
        super.init(
            document: document,
            type: type,
            name: name,
            created: created,
            lastEdited: lastEdited,
            id: id
        )
    }
    
    private enum DB_DocumentCodingKeys: CodingKey {
        case document
        case type
        case name
        case created
        case lastEdited
        case id
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DB_DocumentCodingKeys.self)
        try container.encode(document, forKey: .document)
        try container.encode(type, forKey: .type)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DB_DocumentCodingKeys.self)
        self.init(
            document: try container.decode(Data.self, forKey: .document),
            type: try container.decode(Data.self, forKey: .type),
            name: try container.decode(Data.self, forKey: .name),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Document) {
        self.init(
            document: coreData.documentData!,
            type: coreData.type!,
            name: coreData.name!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!,
            id: coreData.uuid!
        )
    }
}
