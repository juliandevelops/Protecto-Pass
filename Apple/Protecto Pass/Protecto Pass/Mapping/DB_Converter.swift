//
//  DB_Converter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_Mapping.swift on 27.05.23.
//
//  Renamed by Julian Schumacher to DB_Converter.swift on 27.05.23.
//

import CoreData
import Foundation

// TODO: convert notes and tags as well

/// Protocol all converters in this File must conform to
private protocol DatabaseConverterProtocol {
    
    /// The Core Data type of the converter
    associatedtype CoreData : NSManagedObject
    
    /// The encrypted Type of the converter
    associatedtype Encrypted
    
    /// Converts the specified Core Data Object to an encrypted Object
    static func fromCD(_ coreData : CoreData) throws -> Encrypted
    
    /// Converts the specified encrypted Object to a core Data Object
    static func toCD(_ encrypted : Encrypted, context : NSManagedObjectContext) throws -> CoreData
}

/// Converts the stored Databases (e.g. Core Data) into
/// Encrypted Databases and back.
/// Works with Arrays.
internal struct DB_Converter : DatabaseConverterProtocol {
    
    internal static func fromCD(_ coreData: CD_Database) throws -> EncryptedDatabase {
        return try EncryptedDatabase(from: coreData)
    }
    
    internal static func fromCD(_ coreData : [CD_Database]) throws -> [EncryptedDatabase] {
        var result : [EncryptedDatabase] = []
        for db in coreData {
            result.append(try fromCD(db))
        }
        return result
    }
    
    internal static func toCD(_ encrypted: EncryptedDatabase, context: NSManagedObjectContext) throws -> CD_Database {
        let cdDB : CD_Database = CD_Database(context: context)
        cdDB.name = DataConverter.stringToData(encrypted.name)
        cdDB.details = DataConverter.stringToData(encrypted.details)
        for folder in encrypted.folders {
            cdDB.addToFolders(FolderConverter.toCD(folder, context: context))
        }
        for entry in encrypted.entries {
            cdDB.addToEntries(EntryConverter.toCD(entry, context: context))
        }
        for image in encrypted.images {
            cdDB.addToImages(LoadableResourceConverter.toCD(image, context: context))
        }
        for video in encrypted.videos {
            cdDB.addToVideos(LoadableResourceConverter.toCD(video, context: context))
        }
        for document in encrypted.documents {
            cdDB.addToDocuments(LoadableResourceConverter.toCD(document, context: context))
        }
        cdDB.iconName = DataConverter.stringToData(encrypted.iconName)
        cdDB.createdDate = DataConverter.dateToData(encrypted.createdDate)
        cdDB.lastEditedDate = DataConverter.dateToData(encrypted.lastEditedDate)
        cdDB.header = try HeaderConverter.toCD(encrypted.header, context: context)
        cdDB.uuid = DataConverter.uuidToData(encrypted.id)
        return cdDB
    }
}

/// Struct to convert Folders from encrypted to Core Data and backwards
private struct FolderConverter : DatabaseConverterProtocol {
    
    fileprivate static func fromCD(_ coreData: CD_Folder) throws -> Encrypted_DB_Folder {
        return try Encrypted_DB_Folder(from: coreData)
    }
    
    fileprivate static func toCD(_ encrypted: Encrypted_DB_Folder, context: NSManagedObjectContext) -> CD_Folder {
        let cdFolder : CD_Folder = CD_Folder(context: context)
        cdFolder.name = encrypted.name
        cdFolder.details = encrypted.details
        for f in encrypted.folders {
            cdFolder.addToFolders(toCD(f, context: context))
        }
        for e in encrypted.entries {
            cdFolder.addToEntries(EntryConverter.toCD(e, context: context))
        }
        for image in encrypted.images {
            cdFolder.addToImages(LoadableResourceConverter.toCD(image, context: context))
        }
        for video in encrypted.videos {
            cdFolder.addToVideos(LoadableResourceConverter.toCD(video, context: context))
        }
        for document in encrypted.documents {
            cdFolder.addToDocuments(LoadableResourceConverter.toCD(document, context: context))
        }
        cdFolder.iconName = encrypted.iconName
        for doc in encrypted.documents {
            cdFolder.addToDocuments(LoadableResourceConverter.toCD(doc, context: context))
        }
        cdFolder.createdDate = encrypted.createdDate
        cdFolder.lastEditedDate = encrypted.lastEditedDate
        cdFolder.uuid = encrypted.id
        return cdFolder
    }
}

/// Struct to convert Entries from encrypted to Core Data and backwards
private struct EntryConverter : DatabaseConverterProtocol {
    
    fileprivate static func fromCD(_ coreData: CD_Entry) throws -> Encrypted_DB_Entry {
        return try Encrypted_DB_Entry(from: coreData)
    }
    
    fileprivate static func toCD(_ encrypted: Encrypted_DB_Entry, context: NSManagedObjectContext) -> CD_Entry {
        let cdEntry : CD_Entry = CD_Entry(context: context)
        cdEntry.title = encrypted.title
        cdEntry.username = encrypted.encryptedUsername
        cdEntry.password = encrypted.encryptedPassword
        cdEntry.url = encrypted.url
        cdEntry.iconName = encrypted.iconName
        for doc in encrypted.documents {
            cdEntry.addToDocuments(LoadableResourceConverter.toCD(doc, context: context))
        }
        cdEntry.createdDate = encrypted.createdDate
        cdEntry.lastEditedDate = encrypted.lastEditedDate
        cdEntry.uuid = encrypted.id
        return cdEntry
    }
}

/// Struct to convert Images from encrypted to Core Data and backwards
internal struct ImageConverter : DatabaseConverterProtocol {
    internal static func fromCD(_ coreData: CD_Image) throws -> Encrypted_DB_Image {
        return try Encrypted_DB_Image(from: coreData)
    }
    
    internal static func toCD(_ encrypted: Encrypted_DB_Image, context: NSManagedObjectContext) -> CD_Image {
        let cdImage : CD_Image = CD_Image(context: context)
        cdImage.imageData = encrypted.image
        cdImage.compressionQuality = encrypted.quality
        cdImage.createdDate = encrypted.createdDate
        cdImage.lastEditedDate = encrypted.lastEditedDate
        cdImage.uuid = DataConverter.uuidToData(encrypted.id)
        return cdImage
    }
}

internal struct VideoConterter : DatabaseConverterProtocol {
    static func fromCD(_ coreData: CD_Video) throws -> Encrypted_DB_Video {
        return try Encrypted_DB_Video(from: coreData)
    }
    
    static func toCD(_ encrypted: Encrypted_DB_Video, context: NSManagedObjectContext) -> CD_Video {
        let cdVideo : CD_Video = CD_Video(context: context)
        cdVideo.videoData = encrypted.videoData
        cdVideo.createdDate = encrypted.createdDate
        cdVideo.lastEditedDate = encrypted.lastEditedDate
        cdVideo.uuid = DataConverter.uuidToData(encrypted.id)
        return cdVideo
    }
}

/// Struct to convert Documents from encrypted to Core Data and backwards
internal struct DocumentConverter : DatabaseConverterProtocol {
    internal static func fromCD(_ coreData: CD_Document) throws -> Encrypted_DB_Document {
        return try Encrypted_DB_Document(from: coreData)
    }
    
    internal static func toCD(_ encrypted: Encrypted_DB_Document, context: NSManagedObjectContext) -> CD_Document {
        let cdDoc : CD_Document = CD_Document(context: context)
        cdDoc.documentData = encrypted.document
        cdDoc.type = encrypted.type
        cdDoc.name = encrypted.name
        cdDoc.createdDate = encrypted.createdDate
        cdDoc.lastEditedDate = encrypted.lastEditedDate
        cdDoc.uuid = DataConverter.uuidToData(encrypted.id)
        return cdDoc
    }
}

private struct LoadableResourceConverter : DatabaseConverterProtocol {
    internal static func fromCD(_ coreData: CD_LoadableResource) throws -> Encrypted_DB_LoadableResource {
        return Encrypted_DB_LoadableResource(from: coreData)
    }
    
    internal static func toCD(_ encrypted: Encrypted_DB_LoadableResource, context: NSManagedObjectContext) -> CD_LoadableResource {
        let cdLR : CD_LoadableResource = CD_LoadableResource(context: context)
        cdLR.uuid = encrypted.id
        cdLR.name = encrypted.name
        cdLR.thumbnailData = encrypted.thumbnailData
        return cdLR
    }
}


/// NOTE: Encrypted is not encrypted here due to the header never being encrypted
private struct HeaderConverter : DatabaseConverterProtocol {
    internal static func fromCD(_ coreData: CD_DB_Header) throws -> DB_Header {
        return try DB_Header(from: coreData)
    }

    internal static func toCD(_ encrypted: DB_Header, context: NSManagedObjectContext) throws -> CD_DB_Header {
        let cdHeader = CD_DB_Header(context: context)
        cdHeader.allowBiometrics = encrypted.allowBiometrics
        cdHeader.biometricsTimeout = encrypted.biometricsTimeout
        cdHeader.encryption = encrypted.encryption.rawValue
        cdHeader.storageType = encrypted.storageType.rawValue
        cdHeader.salt = encrypted.salt
        cdHeader.keyParams = CD_DB_HeaderKeyParameters(context: context)
        guard cdHeader.keyParams != nil else {
            throw DatabaseError.conversionError
        }
        cdHeader.keyParams!.iterationsCount = Int64(encrypted.keyParameters.iterationsCount)
        cdHeader.keyParams!.keyLength = Int64(encrypted.keyParameters.keyLength)
        cdHeader.keyParams!.laneCount = Int64(encrypted.keyParameters.laneCount)
        cdHeader.keyParams!.memoryLimit = Int64(encrypted.keyParameters.memoryLimit)
        cdHeader.key = encrypted.key
        cdHeader.path = encrypted.path
        cdHeader.version = encrypted.version.coreDataCompositiveTypeRepresentation
        return cdHeader
    }
}
