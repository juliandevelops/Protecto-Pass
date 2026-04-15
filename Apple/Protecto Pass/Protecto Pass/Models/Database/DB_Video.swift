//
//  DB_Video.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 02.06.24.
//

import Foundation

/// The general super class of all Videos stored in this App
internal class General_DB_Video<DataType, DateType, TagType> : DatabaseContent<DateType, UUID, TagType> {

    /// The Video Data
    internal let videoData : DataType

    internal init(
        videoData : DataType,
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id: UUID,
        tags : [TagType]
    ) {
        self.videoData = videoData
        super.init(
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}

/// The decrypted Data Strcuture for Videos stored in this App
internal final class DB_Video : General_DB_Video<Data, Date, DB_Tag>, DecryptedDataStructure {
    static func == (lhs: DB_Video, rhs: DB_Video) -> Bool {
        return lhs.videoData == rhs.videoData &&
        lhs.createdDate == rhs.createdDate &&
        lhs.lastEditedDate == rhs.lastEditedDate &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(videoData)
        hasher.combine(createdDate)
        hasher.combine(lastEditedDate)
        hasher.combine(id)
    }
}

/// The encrypted Data Strcuture for Videos stored in this App
internal final class Encrypted_DB_Video : General_DB_Video<Data, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    internal override init(
        videoData: Data,
        createdDate: Data,
        lastEditedDate: Data,
        lastAccessedDate: Data,
        id: UUID,
        tags: [Encrypted_DB_Tag]
    ) {
        super.init(
            videoData: videoData,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }

    private enum DB_VideoCodingKeys: CodingKey {
        case videoData
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DB_VideoCodingKeys.self)
        try container.encode(videoData, forKey: .videoData)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
    
    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DB_VideoCodingKeys.self)
        self.init(
            videoData: try container.decode(Data.self, forKey: .videoData),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(UUID.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)

        )
    }
    
    internal convenience init(from coreData : CD_Video) throws {
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            videoData: coreData.videoData!,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: DataConverter.dataToUUID(coreData.uuid!),
            tags: localTags
        )
    }
}
