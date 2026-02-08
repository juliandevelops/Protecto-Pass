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
///
/// # Params
/// DE: Date
/// DA: Icon Name Data
/// DO: Documents type
internal class DB_NativeType<DE, DA, DO> : DatabaseContent<DE>, ObservableObject {

    /// The Name of the SF-Symbol representing what this
    /// Database Content is
    @Published internal var iconName : DA
    
    @Published internal var documents : [DO]
    
    internal init(
        iconName: DA,
        documents : [DO],
        created : DE,
        lastEdited : DE,
        id : UUID
    ) {
        self.iconName = iconName
        self.documents = documents
        super.init(created: created, lastEdited: lastEdited, id: id)
    }
}
