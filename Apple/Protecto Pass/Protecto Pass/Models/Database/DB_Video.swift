//
//  DB_Video.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 02.06.24.
//

import Foundation

/// The general super class of all Videos stored in this App
internal class General_DB_Video<DA, DE> : DatabaseContent<DE> {
    
    /// The Video Data
    internal let video : DA
    
    internal init(
        video : DA,
        created : DE,
        lastEdited : DE,
        id: UUID
    ) {
        self.video = video
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}

/// The decrypted Data Strcuture for Videos stored in this App
internal final class DB_Video : General_DB_Video<Data, Date>, DecryptedDataStructure {
    static func == (lhs: DB_Video, rhs: DB_Video) -> Bool {
        return lhs.video == rhs.video && lhs.created == rhs.created && lhs.lastEdited == rhs.lastEdited && lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(video)
        hasher.combine(created)
        hasher.combine(lastEdited)
        hasher.combine(id)
    }
}

/// The encrypted Data Strcuture for Videos stored in this App
internal final class Encrypted_DB_Video : General_DB_Video<Data, Data>, EncryptedDataStructure {
    
    private enum DB_VideoCodingKeys: CodingKey {
        case video
        case created
        case lastEdited
        case id
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DB_VideoCodingKeys.self)
        try container.encode(video, forKey: .video)
        try container.encode(created, forKey: .created)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(id, forKey: .id)
    }
    
    override internal init(
        video: Data,
        created: Data,
        lastEdited: Data,
        id: UUID
    ) {
        super.init(video: video, created: created, lastEdited: lastEdited, id: id)
    }
    
    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DB_VideoCodingKeys.self)
        self.init(
            video: try container.decode(Data.self, forKey: .video),
            created: try container.decode(Data.self, forKey: .created),
            lastEdited: try container.decode(Data.self, forKey: .lastEdited),
            id: try container.decode(UUID.self, forKey: .id)
        )
    }
    
    internal convenience init(from coreData : CD_Video) {
        self.init(
            video: coreData.videoData!,
            created: coreData.created!,
            lastEdited: coreData.lastEdited!,
            id: coreData.uuid!
        )
    }
}
