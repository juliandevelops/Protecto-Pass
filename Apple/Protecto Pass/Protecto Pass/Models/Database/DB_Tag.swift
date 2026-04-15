//
//  DB_Tag.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 09.02.26.
//

import Foundation

/// General super class of the Database Tag.
/// A Tag is a simple and fast identifier you can apply to any
/// object in the database
internal class General_DB_Tag<DataType, ColorType> {

    /// Name or title of the tag.
    /// This is the main identifier of the tag.
    /// It also is the only identifier which means there can't be two tags with the same name
    internal var name : DataType

    /// The color to represent this Tag in the UI
    internal var color : ColorType

    
    internal init(name: DataType, color: ColorType) {
        self.name = name
        self.color = color
    }
}

/// Decrypted Tag class used in this app.
internal final class DB_Tag : General_DB_Tag<String, DB_Color>, DecryptedDataStructure {

    static func == (lhs: DB_Tag, rhs: DB_Tag) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(color)
    }
}

/// The encrypted version of the tag in this app
internal final class Encrypted_DB_Tag : General_DB_Tag<Data, Encrypted_DB_Color>, EncryptedDataStructure {

    internal convenience init(from coreData : CD_DB_Tag) throws {
        self.init(
            name: coreData.name!,
            color: try Encrypted_DB_Color(from: coreData.color)
        )
    }

    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: TagCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            color: try container.decode(Encrypted_DB_Color.self, forKey: .color)
        )
    }

    /// Coding Keys to encode or decode this Tag
    private enum TagCodingKeys: CodingKey {
        case name
        case color
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: TagCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
    }
}
