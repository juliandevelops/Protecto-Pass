//
//  DatabaseContent.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.08.23.
//

import Foundation

/// The Super class of most Database Content Objects
/// that are stored within the App
internal class DatabaseContent<DateType, IDType, TagType> : Identifiable {

    /// The Date of creation for this Object
    internal let createdDate : DateType

    /// The last edit date indicates when this
    /// Object was edited the last time
    internal var lastEditedDate : DateType

    /// The time this object was last accessed at
    internal var lastAccessedDate : DateType

    /// The ID itself can also be encrypted, so this is a type
    internal let id : IDType

    /// Tags to match with this content inside the database
    internal var tags : [TagType]


    internal init(
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : IDType,
        tags : [TagType]
    ) {
        self.createdDate = createdDate
        self.lastEditedDate = lastEditedDate
        self.lastAccessedDate = lastAccessedDate
        self.id = id
        self.tags = tags
    }
}
