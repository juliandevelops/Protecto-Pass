//
//  ME_DataStructure.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.08.23.
//

import Foundation

/// ME Data Structure is short for Multiple Entity Data Structure,
/// which is used to store multiple entities in one Object.
/// Objects which have a folder-like structure or features, inherit from this class
internal class ME_DataStructure<DA, DE, F, E, L> : NativeType<DE, DA, L> {
    
    /// The Name of this Data Structure
    @Published internal var name : DA
    
    /// A closer description of this Object
    ///
    /// # Core Data
    /// This reflects the objectDescription Property in
    /// Core Data, because the description parameter is
    /// already taken.
    @Published internal var description : DA
    
    @Published internal var folders : [F]
    
    @Published internal var entries : [E]
    
    @Published internal var images : [L]
    
    @Published internal var videos : [L]
    
    internal init(
        name : DA,
        description : DA,
        folders : [F],
        entries : [E],
        images : [L],
        videos : [L],
        iconName : DA,
        documents : [L],
        created : DE,
        lastEdited : DE,
        id : UUID
    ) {
        self.name = name
        self.description = description
        self.folders = folders
        self.entries = entries
        self.images = images
        self.videos = videos
        super.init(
            iconName: iconName,
            documents: documents,
            created: created,
            lastEdited: lastEdited,
            id: id
        )
    }
    
    internal func getImagesAndVideos() -> [L] {
        images + videos
    }
}

/// Protocol which most of the Decrypted Data Structures conform to in order to use them in
/// UI Components such as Picker and a generated List
internal protocol DecryptedDataStructure : Hashable, Identifiable {}

/// Protocol which all of the encrypted Data Structures must conforms to in order
/// to store them in a File
internal protocol EncryptedDataStructure : Codable {}
