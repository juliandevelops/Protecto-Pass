//
//  NativeType.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.08.23.
//

import Foundation
import Combine

/// Superclass of every Native Type implemented in this App, that could not have
/// been implemented with a default Type
internal class DB_NativeType<DateType, DataType, DocumentType, IDType, TagType> : DatabaseContent<DateType, IDType, TagType>, ObservableObject {

    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    @Published internal var iconName : DataType

    /// The documents mapped to this native type in the database
    @Published internal var documents : [DocumentType]

    /// The notes (not DB\_Notes) but rather a string
    @Published internal var details : DataType


    internal init(
        iconName: DataType,
        documents : [DocumentType],
        details : DataType,
        createdDate : DateType,
        lastEditedDate : DateType,
        lastAccessedDate : DateType,
        id : IDType,
        tags: [TagType]
    ) {
        self.iconName = iconName
        self.documents = documents
        self.details = details
        super.init(
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}
