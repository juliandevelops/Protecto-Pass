//
//  DatabaseContent.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.08.23.
//

import Foundation

/// The Super class of most Database Content Objects
/// that are stored within the App
///
/// # Params
/// D: Date identifier
internal class DatabaseContent<D> : Identifiable {
    
    /// The Date of creation for this Object
    internal let created : D
    
    /// The last edit date indicates when this
    /// Object was edited the last time
    internal var lastEdited : D
    
    internal let id : UUID
    
    internal init(
        created : D,
        lastEdited : D,
        id : UUID
    ) {
        self.created = created
        self.lastEdited = lastEdited
        self.id = id
    }
}
