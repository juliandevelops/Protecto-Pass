//
//  DB_Image.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.08.23.
//

import Foundation
import UIKit

/// The General super class of the DB Images.
/// An Image is an external resource which is loaded on demand.
/// Due to that reason, DB\_Images cannot have encrypted ids as they are referenced by those.
/// All images (whether it is encrypted or decrypted) use UUID as id.
internal class General_DB_Image<NameType, DataType, QualityType, DateType, TagType> : DatabaseContent<DateType, UUID, TagType> {

    /// The name of this image as the filename was on the users device
    internal var name : NameType

    /// The actual Image or data of it..
    internal let image : DataType

    /// The compression quality if the Type was
    /// jpeg
    internal let quality : QualityType


    internal init(
        name : NameType,
        image : DataType,
        quality : QualityType,
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : UUID,
        tags : [TagType]
    ) {
        self.name = name
        self.image = image
        self.quality = quality
        super.init(
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}

/// The Decrypted Data Structure for Images stored in this App.
/// This struct contains all data in decrypted version, a plaintext image if you want
internal final class DB_Image : General_DB_Image<String, UIImage, Double, Date, DB_Tag>, DecryptedDataStructure {

    static func == (lhs: DB_Image, rhs: DB_Image) -> Bool {
        return lhs.image == rhs.image &&
        lhs.quality == rhs.quality &&
        lhs.id == rhs.id &&
        lhs.tags == rhs.tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(image)
        hasher.combine(quality)
        hasher.combine(id)
        hasher.combine(createdDate)
        hasher.combine(lastEditedDate)
        hasher.combine(tags)
    }

    /// The preview Image to use in SwiftUI Previews
    internal static let previewImage : DB_Image = DB_Image(
        name: "Test Image.jpg",
        image: UIImage(systemName: "car")!,
        quality: 0.8,
        createdDate: Date.now,
        lastEditedDate: Date.now,
        lastAccessedDate: Date.now,
        id: UUID(),
        tags: []
    )
}

/// The Encrypted Data Structure being used when the Database is still encrypted.
internal final class Encrypted_DB_Image : General_DB_Image<Data, Data, Data, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    internal override convenience init(
        name: Data,
        image: Data,
        quality: Data,
        createdDate: Data,
        lastEditedDate: Data,
        lastAccessedDate: Data,
        id: UUID,
        tags: [Encrypted_DB_Tag]
    ) {
        self.init(
            name: name,
            image: image,
            quality: quality,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }

    internal convenience init(from coreData : CD_Image) throws {
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            name: coreData.name!,
            image: coreData.imageData!,
            quality: coreData.compressionQuality!,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: DataConverter.dataToUUID(coreData.uuid!),
            tags: localTags
        )
    }

    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: DB_ImageCodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            image: try container.decode(Data.self, forKey: .image),
            quality: try container.decode(Data.self, forKey: .quality),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(UUID.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }

    /// Coding Keys to encode or decode this Image
    private enum DB_ImageCodingKeys: CodingKey {
        case name
        case image
        case quality
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DB_ImageCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(quality, forKey: .quality)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
}
