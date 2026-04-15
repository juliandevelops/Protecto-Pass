//
//  Entry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.03.23.
//

import Foundation
import SwiftUI

/// The general Database Entry class.
/// This class defines an entry with all it's parameters that are part of the encrypted as well as the decrypted entry class.
internal class General_DB_Entry<
    DataType,
    URLType,
    DateType,
    DocumentType,
    IDType,
    TagType
> : DB_NativeType<
    DateType,
    DataType,
    DocumentType,
    IDType,
    TagType
> {

    /// The Title of this Entry
    internal var title : DataType

    /// The Username connected to this Entry.
    /// The username is always stored in an encrypted way due to it's
    /// sensitive nature.
    internal var encryptedUsername : Data

    /// The Password stored with this Entry.
    /// Due to the sensitive nature of passwords,
    /// a password in never stored decryptedly longer as needed,
    /// so with the initial decryption sensitive informaiton - such as passwords -
    /// will stay encrypted and will only be decrypted on demand
    /// into the according buffer.
    ///
    /// See DB\_Entry subclass for more information
    internal var encryptedPassword : Data

    /// The URL this Entry is connected to
    internal var url : URLType

    internal init(
        title: DataType,
        encryptedUsername: Data,
        encryptedPassword: Data,
        url: URLType,
        details: DataType,
        iconName : DataType,
        documents : [DocumentType],
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : IDType,
        tags: [TagType]
    ) {
        self.title = title
        self.encryptedUsername = encryptedUsername
        self.encryptedPassword = encryptedPassword
        self.url = url
        super.init(
            iconName: iconName,
            documents: documents,
            details: details,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}

/// The Struct representing an Entry
/// while this App is running.
/// This structure is the only one containing decrypted sensitive data.
/// All sensitive data will only be decrypted into a buffer and must be overwritten afterwords.
internal final class DB_Entry : General_DB_Entry<String, URL?, Date, DB_LoadableResource, UUID, DB_Tag>, DecryptedDataStructure {

    /// This buffer is used to store the username after decryption on demand.
    /// As sensitive information are only decrypted on demand when viewing the entry,
    /// this buffer is of a data type to be able to clear it out after using it.
    ///
    /// # Workflow
    ///  When viewing an entry, the required sensitive information will be decrypted
    ///  on demand and stored in the according buffer.
    ///  This buffer will be described by a string element in the UI.
    ///  After closing the view and not using this buffer, this buffer must be overwritten,
    ///  preferably with memset\_s (DO NOT USE memset as it can be removed by compiler optimization).
    ///  Only after overwriting this buffer the view can be closed.
    ///
    ///  ## Background Information
    ///  Overwriting this buffer does not garantuee that all data are cleared from RAM.
    ///  When displaying the username in the UI, it must be copied into a string which cannot be overwritten
    ///  or deleted by the developer.
    ///  Swifts ARC (Automativ Reference Counting) will deallocate or remove the string when not needed anymore.
    ///  This risk is accepted as the attack requires root access to memory.
    internal var decryptedUsernameBuffer : Data

    /// This buffer is used to store the password after decryption on demand.
    /// As sensitive information are only decrypted on demand when viewing the entry,
    /// this buffer is of a data type to be able to clear it out after using it.
    ///
    /// # Workflow
    ///  When viewing an entry, the required sensitive information will be decrypted
    ///  on demand and stored in the according buffer.
    ///  This buffer will be described by a string element in the UI.
    ///  After closing the view and not using this buffer, this buffer must be overwritten,
    ///  preferably with memset\_s (DO NOT USE memset as it can be removed by compiler optimization).
    ///  Only after overwriting this buffer the view can be closed.
    ///
    ///  ## Background Information
    ///  Overwriting this buffer does not garantuee that all data are cleared from RAM.
    ///  When displaying the password in the UI, it must be copied into a string which cannot be overwritten
    ///  or deleted by the developer.
    ///  Swifts ARC (Automativ Reference Counting) will deallocate or remove the string when not needed anymore.
    ///  This risk is accepted as the attack requires root access to memory.
    internal var decryptedPasswordBuffer : Data

    internal override convenience init(
        title: String,
        encryptedUsername: Data,
        encryptedPassword: Data,
        url: URL?,
        details: String,
        iconName: String,
        documents: [DB_LoadableResource],
        createdDate: Date,
        lastEditedDate: Date,
        lastAccessedDate: Date,
        id: UUID,
        tags: [DB_Tag]
    ) {
        self.init(
            title: title,
            encryptedUsername: encryptedUsername,
            encryptedPassword: encryptedPassword,
            url: url,
            details: details,
            iconName: iconName,
            documents: documents,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }

    static func == (lhs: DB_Entry, rhs: DB_Entry) -> Bool {
        return lhs.title == rhs.title &&
        lhs.encryptedUsername == rhs.encryptedUsername &&
        lhs.encryptedPassword == rhs.encryptedPassword &&
        lhs.url == rhs.url &&
        lhs.details == rhs.details &&
        lhs.createdDate == rhs.createdDate &&
        lhs.lastEditedDate == rhs.lastEditedDate &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(iconName)
        hasher.combine(createdDate)
        hasher.combine(lastEditedDate)
        hasher.combine(title)
        hasher.combine(encryptedUsername)
        hasher.combine(encryptedPassword)
        hasher.combine(url)
        hasher.combine(details)
    }


    /// The static preview entry to use in SwiftUI previews
    internal static let previewEntry : DB_Entry = DB_Entry(
        title: "Test Entry",
        encryptedUsername: DataConverter.stringToData("user"),
        encryptedPassword: DataConverter.stringToData("testPassword"),
        url: URL(string: "https://github.com/V3Sofficial/Protecto-Pass", encodingInvalidCharacters: false),
        details: "This is a preview Entry, only to use in previews and tests",
        iconName: "doc",
        documents: [],
        createdDate: Date.now,
        lastEditedDate: Date.now,
        lastAccessedDate: Date.now,
        id: UUID(),
        tags: []
    )
}

/// The Encrypted Entry storing all the
/// Data of an Entry secure and encrypted
internal final class Encrypted_DB_Entry : General_DB_Entry<Data, Data, Data, Encrypted_DB_LoadableResource, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    internal override init(
        title: Data,
        encryptedUsername: Data,
        encryptedPassword: Data,
        url: Data,
        details: Data,
        iconName: Data,
        documents: [Encrypted_DB_LoadableResource],
        createdDate: Data,
        lastEditedDate: Data,
        lastAccessedDate: Data,
        id: Data,
        tags: [Encrypted_DB_Tag]
    ) {
        super.init(
            title: title,
            encryptedUsername: encryptedUsername,
            encryptedPassword: encryptedPassword,
            url: url,
            details: details,
            iconName: iconName,
            documents: documents,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }

    private enum EntryCodingKeys: CodingKey {
        case title
        case encryptedUsername
        case encryptedPassword
        case url
        case notes
        case iconName
        case documents
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EntryCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(encryptedUsername, forKey: .encryptedUsername)
        try container.encode(encryptedPassword, forKey: .encryptedPassword)
        try container.encode(url, forKey: .url)
        try container.encode(details, forKey: .notes)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: EntryCodingKeys.self)
        self.init(
            title: try container.decode(Data.self, forKey: .title),
            encryptedUsername: try container.decode(Data.self, forKey: .encryptedUsername),
            encryptedPassword: try container.decode(Data.self, forKey: .encryptedPassword),
            url: try container.decode(Data.self, forKey: .url),
            details: try container.decode(Data.self, forKey: .notes),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .documents),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(Data.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }
    
    internal init(from coreData : CD_Entry) throws {
        var localDocuments : [Encrypted_DB_LoadableResource] = []
        for document in coreData.documents! {
            localDocuments.append(Encrypted_DB_LoadableResource(from: document as! CD_LoadableResource))
        }
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        super.init(
            title: coreData.title!,
            encryptedUsername: coreData.username!,
            encryptedPassword: coreData.password!,
            url: coreData.url!,
            details: coreData.notes!,
            iconName: coreData.iconName!,
            documents: localDocuments,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: coreData.uuid!,
            tags: localTags
        )
    }
}
