//
//  DB_Header.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_DB_Header on 28.03.23.
//
//  Renamed by Julian Schumacher to DB_Header on 29.03.23.
//

import Foundation

/// The Header for an encrypted Database containing the
/// important information about the Database
internal struct DB_Header : Codable, Hashable {

    private static let defaultIterationsCount : Int64 = 500000

    private static let defaultKeyLength : Int32 = 32

    internal init(
        allowBiometrics : Bool,
        biometricsTimeout : Int64,
        encryption : Cryptography.Encryption,
        storageType : Storage.StorageType,
        salt : Data,
        iterationsCount : Int64,
        keyLength : Int32,
        key : Data,
        path : URL? = nil,
        version : Int16
    ) {
        self.allowBiometrics = allowBiometrics
        self.biometricsTimeout = biometricsTimeout
        self.encryption = encryption
        self.storageType = storageType
        self.salt = salt
        self.iterationsCount = iterationsCount
        self.keyLength = keyLength
        self.key = key
        self.path = path
        self.version = version
    }

    internal var allowBiometrics : Bool

    internal var biometricsTimeout : Int64

    ///The Enum telling the App
    ///which Encryption was used to encrypt
    ///the Database
    internal var encryption : Cryptography.Encryption
    
    /// The Enum telling the App how the Database
    /// is stored.
    internal var storageType : Storage.StorageType
    
    /// The Salt to secure the password of the database
    /// against rainbow attacks
    internal var salt : Data

    /// The count of iterations in key derivation
    internal var iterationsCount : Int64

    /// The length of the derived key
    internal var keyLength : Int32

    internal var key : Data

    internal var version : Int16

    /// The Path where to store the Database on
    /// the System or Cloud
    internal var path : URL?
    
    /// A preview header to use in previews and tests.
    /// The salt is still dynamically generated every time
    internal static let previewHeader : DB_Header = DB_Header(
        allowBiometrics: true,
        biometricsTimeout: 500000,
        encryption: .AES256,
        storageType: .CoreData,
        salt: try! PasswordGenerator.generateSalt(),
        iterationsCount: 500000,
        keyLength: 32,
        key: try! PasswordGenerator.generateSalt(),
        path: URL(string: "/"),
        version: 1
    )

    /// Coding Keys for encoding Header to Encoder
    private enum HeaderCodingKeys: CodingKey {
        case allowBiometrics
        case biometricsTimeout
        case encryption
        case storageType
        case salt
        case iterationsCount
        case keyLength
        case key
        case path
        case version
    }

    /// Encoding header to proveded encoder
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HeaderCodingKeys.self)
        try container.encode(allowBiometrics, forKey: .allowBiometrics)
        try container.encode(biometricsTimeout, forKey: .biometricsTimeout)
        try container.encode(encryption.rawValue, forKey: .encryption)
        try container.encode(storageType.rawValue, forKey: .storageType)
        try container.encode(salt, forKey: .salt)
        try container.encode(iterationsCount, forKey: .iterationsCount)
        try container.encode(keyLength, forKey: .keyLength)
        try container.encode(key, forKey: .key)
        try container.encode(path, forKey: .path)
        try container.encode(version, forKey: .version)
    }

    /// Decrypting Header from provided Devoder
    internal init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: HeaderCodingKeys.self)
        self.init(
            allowBiometrics: try container.decode(Bool.self, forKey: .allowBiometrics),
            biometricsTimeout: try container.decode(Int64.self, forKey: .biometricsTimeout),
            encryption: Cryptography.Encryption(rawValue: try container.decode(String.self, forKey: .encryption))!,
            storageType: Storage.StorageType(rawValue: try container.decode(String.self, forKey: .storageType))!,
            salt: try container.decode(Data.self, forKey: .salt),
            iterationsCount: try container.decode(Int64.self, forKey: .iterationsCount),
            keyLength: try container.decode(Int32.self, forKey: .keyLength),
            key: try container.decode(Data.self, forKey: .key),
            path: try container.decode(URL?.self, forKey: .path),
            version: try container.decode(Int16.self, forKey: .version)
        )
    }

    internal init(from coreData : CD_DB_Header) {
        self.init(
            allowBiometrics: coreData.allowBiometrics,
            biometricsTimeout: coreData.biometricsTimeout,
            encryption: Cryptography.Encryption(rawValue: coreData.encryption!)!,
            storageType: Storage.StorageType(rawValue: coreData.storageType!)!,
            salt: coreData.salt!,
            iterationsCount: coreData.iterationsCount,
            keyLength: coreData.keyLength,
            key: coreData.key!,
            path: coreData.path,
            version: coreData.version
        )
    }
}
