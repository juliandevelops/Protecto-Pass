//
//  ME_DataStructure.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.08.23.
//

import Foundation
import Combine

/// ME Data Structure is short for Multiple Entity Data Structure,
/// which is used to store multiple entities in one Object.
/// Objects which have a folder-like structure or features, inherit from this class
///
/// Some content will only be referenced here and has to be loaded on demand.
internal class DB_ME_DataStructure<
    DataType,
    DateType,
    FolderType,
    EntryType,
    LoadableResourceType,
    CreditCardType,
    NotesType,
    PasskeyType,
    IDType,
    TagType
> : DB_NativeType<DateType, DataType, LoadableResourceType, IDType, TagType> {

    /// The Name of this Data Structure
    /// This will be the name of the folder or database (or any other structure if more to come)
    @Published internal var name : DataType

    /// All folders this datastructure holds.
    /// These folder will not be references, but rather stored directly.
    @Published internal var folders : [FolderType]

    /// All entries in this datastructures top level.
    /// Entries within a subfolder are stored in that folder which again is of this type.
    /// Only top level entries are to be stored here.
    @Published internal var entries : [EntryType]

    /// All images referenced in this data structures top level.
    /// Images are onbly references and must be load on demand.
    @Published internal var images : [LoadableResourceType]

    /// All videos referenced in this data structures top level.
    /// Videos are only referenced and must be loaded on demand.
    @Published internal var videos : [LoadableResourceType]

    /// All credit cards stored in at top level of this data structure.
    /// Credit cards are stored directly in the data structure.
    @Published internal var creditCards : [CreditCardType]

    /// All notes stored in this data structures top level.
    /// Notes are stored directly inside the data structure.
    @Published internal var notes : [NotesType]

    /// All passkeys stored in this data strctures top level.
    /// Passkeys are stored directly inide the data structure.
    @Published internal var passkeys : [PasskeyType]

    internal init(
        name : DataType,
        details: DataType,
        folders : [FolderType],
        entries : [EntryType],
        images : [LoadableResourceType],
        videos : [LoadableResourceType],
        creditCards: [CreditCardType],
        notes: [NotesType],
        passkeys : [PasskeyType],
        iconName : DataType,
        documents : [LoadableResourceType],
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : IDType,
        tags: [TagType]
    ) {
        self.name = name
        self.folders = folders
        self.entries = entries
        self.images = images
        self.videos = videos
        self.creditCards = creditCards
        self.notes = notes
        self.passkeys = passkeys
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

    /// Returns images as well as videos in one array.
    internal func getImagesAndVideos() -> [LoadableResourceType] {
        images + videos
    }
}

/// Protocol which most of the Decrypted Data Structures conform to in order to use them in
/// UI Components such as Picker and a generated List
internal protocol DecryptedDataStructure : Hashable, Identifiable, Equatable {}

/// Protocol which all of the encrypted Data Structures must conforms to in order
/// to store them in a File
internal protocol EncryptedDataStructure : Codable {}
