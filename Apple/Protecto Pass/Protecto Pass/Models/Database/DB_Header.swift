//
//  DB_Header.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as CD_DB_Header on 28.03.23.
//
//  Renamed by Julian Schumacher to DB_Header on 29.03.23.
//

import Foundation

/// The Database Versioning Scheme.
/// This includes several different versions indicating different types of changes.
internal struct DatabaseVersioningScheme : Equatable, Hashable {

    /// Identifier for the major database version in the dictionary representation of this object.
    /// This representation is used in the Core Data compositive type
    private static let CD_COMPOSITIVE_MAJOR_VERSION_IDENTIFIER : String = "majorVersion"

    /// Identifier for the minor database version in the dictionary representation of this object.
    /// This representation is used in the Core Data compositive type
    private static let CD_COMPOSITIVE_MINOR_VERSION_IDENTIFIER : String = "minorVersion"

    /// Identifier for the fix database version in the dictionary representation of this object.
    /// This representation is used in the Core Data compositive type
    private static let CD_COMPOSITIVE_FIX_VERSION_IDENTIFIER : String = "fixVersion"

    /// Identifier for the build database version in the dictionary representation of this object.
    /// This representation is used in the Core Data compositive type
    private static let CD_COMPOSITIVE_BUILD_VERSION_IDENTIFIER : String = "buildVersion"

    /// Current database version
    internal static let CURRENT_APP_DB_VERSION : DatabaseVersioningScheme = DatabaseVersioningScheme(
        majorVersion: 1,
        minorVersion: 1,
        fixVersion: 1,
        buildVersion: 1
    )

    /// The major version of this database.
    /// Changing this will incllude breaking changes.
    internal var majorVersion : Int

    /// Minor version change.
    /// This keeps backwords compability include minor changes
    internal var minorVersion : Int

    /// The fix version. Not notable but used for debug
    internal var fixVersion : Int

    /// The version of the build of the database
    internal var buildVersion : Int

    /// Database version as a string.
    /// It follows the general principle of major - minor - fix and build verison in the format
    /// `major`.`minor`.`fix`:`build`.
    internal var stringRepresentation : String {
        "\(majorVersion).\(minorVersion).\(fixVersion):\(buildVersion)"
    }

    /// A representation of this object as a dictionary used in the core data compositive type.
    /// This used the CD\_COMPOSITIVE identifiers of this object as keys
    internal var coreDataCompositiveTypeRepresentation : [String : Any] {
        [
            DatabaseVersioningScheme.CD_COMPOSITIVE_MAJOR_VERSION_IDENTIFIER : majorVersion,
            DatabaseVersioningScheme.CD_COMPOSITIVE_MINOR_VERSION_IDENTIFIER : minorVersion,
            DatabaseVersioningScheme.CD_COMPOSITIVE_FIX_VERSION_IDENTIFIER : fixVersion,
            DatabaseVersioningScheme.CD_COMPOSITIVE_BUILD_VERSION_IDENTIFIER : buildVersion
        ]
    }


    internal init(majorVersion: Int, minorVersion: Int, fixVersion: Int, buildVersion: Int) {
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.fixVersion = fixVersion
        self.buildVersion = buildVersion
    }

    internal init(from stringRepresentation: String) throws {
        let splittedBuild = stringRepresentation.split(separator: ":")
        guard splittedBuild.count == 2 else { throw DatabaseError.invalidVersion }
        let splittedVersions = splittedBuild[0].split(separator: ".")
        guard splittedVersions.count == 3 else { throw DatabaseError.invalidVersion }
        guard let parsedMajor = Int(splittedVersions[0]),
              let parsedMinor = Int(splittedVersions[1]),
              let parsedFix = Int(splittedVersions[2]),
              let parsedBuild = Int(splittedBuild[0])
        else {
            throw DatabaseError.invalidVersion
        }
        self.init(
            majorVersion: parsedMajor,
            minorVersion: parsedMinor,
            fixVersion: parsedFix,
            buildVersion: parsedBuild
        )
    }

    internal init(from coreData : [String : Any]?) throws {
        guard let cd = coreData else { throw DatabaseError.nilData }
        guard let parsedMajor = cd[DatabaseVersioningScheme.CD_COMPOSITIVE_MAJOR_VERSION_IDENTIFIER] as? Int,
              let parsedMinor = cd[DatabaseVersioningScheme.CD_COMPOSITIVE_MINOR_VERSION_IDENTIFIER] as? Int,
              let parsedFix = cd[DatabaseVersioningScheme.CD_COMPOSITIVE_FIX_VERSION_IDENTIFIER] as? Int,
              let parsedBuild = cd[DatabaseVersioningScheme.CD_COMPOSITIVE_BUILD_VERSION_IDENTIFIER] as? Int
        else {
            throw DatabaseError.invalidVersion
        }
        self.init(
            majorVersion: parsedMajor,
            minorVersion: parsedMinor,
            fixVersion: parsedFix,
            buildVersion: parsedBuild
        )
    }

    /// A preview database versioning scheme to use in SwiftUI previews and tests
    fileprivate static let previewDatabaseVersioningScheme : DatabaseVersioningScheme = DatabaseVersioningScheme(
        majorVersion: 1,
        minorVersion: 0,
        fixVersion: 0,
        buildVersion: 1
    )
}

/// Key parameters used for key derivation of database
internal struct DB_HeaderKeyParameters : Codable, Equatable, Hashable {

    /// Preview parameters used in tests and UI previews
    fileprivate static let previewParams : DB_HeaderKeyParameters = DB_HeaderKeyParameters(
        iterationsCount: DEFAULT_ITERATIONS_COUNT,
        keyLength: DEFAULT_KEY_LENGTH,
        memoryLimit: DEFAULT_MEMORY_LIMIT,
        laneCount: DEFAULT_LANE_COUNT,
        threadCount: DEFAULT_THREAD_COUNT,
        argon2idVerson: DEFAULT_ARGON2_VERSION
    )

    /// Default iterations count for a new database.
    /// This is a fallback value, dynamic values can be calculated on the deivce
    private static let DEFAULT_ITERATIONS_COUNT : UInt32 = 500000

    /// The default length of a newly generated key
    private static let DEFAULT_KEY_LENGTH : UInt32 = 32

    private static let DEFAULT_MEMORY_LIMIT : UInt32 = 16 * 1024 * 1024

    private static let DEFAULT_LANE_COUNT : UInt32 = 1

    private static let DEFAULT_THREAD_COUNT : UInt32 = 1

    private static let DEFAULT_ARGON2_VERSION : UInt32 = 0x13

    /// The count of iterations in key derivation
    internal var iterationsCount : UInt32

    /// The length of the derived key
    internal var keyLength : UInt32

    /// Memory limit for argon2 key derivation
    internal var memoryLimit : UInt32

    /// Lane count for argon2 key derivation
    internal var laneCount : UInt32

    /// Thread count for argon2 key derivation
    internal var threadCount: UInt32

    /// version for argon2 key derivation
    internal var argon2idVerson : UInt32

    internal init(
        iterationsCount: UInt32,
        keyLength: UInt32,
        memoryLimit: UInt32,
        laneCount: UInt32,
        threadCount: UInt32,
        argon2idVerson: UInt32
    ) {
        self.iterationsCount = iterationsCount
        self.keyLength = keyLength
        self.memoryLimit = memoryLimit
        self.laneCount = laneCount
        self.threadCount = threadCount
        self.argon2idVerson = argon2idVerson
    }

    internal enum DB_HeaderKeyParams_CodingKeys : CodingKey {
        case iterationsCount
        case keyLength
        case memoryLimit
        case laneCount
        case threadCount
        case argon2idVerson
    }

    internal func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DB_HeaderKeyParams_CodingKeys.self)
        try container.encode(iterationsCount, forKey: .iterationsCount)
        try container.encode(keyLength, forKey: .keyLength)
        try container.encode(memoryLimit, forKey: .memoryLimit)
        try container.encode(laneCount, forKey: .laneCount)
        try container.encode(threadCount, forKey: .threadCount)
        try container.encode(argon2idVerson, forKey: .argon2idVerson)
    }

    internal init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DB_HeaderKeyParams_CodingKeys.self)
        self.iterationsCount = try container.decode(UInt32.self, forKey: .iterationsCount)
        self.keyLength = try container.decode(UInt32.self, forKey: .keyLength)
        self.memoryLimit = try container.decode(UInt32.self, forKey: .memoryLimit)
        self.laneCount = try container.decode(UInt32.self, forKey: .laneCount)
        self.threadCount = try container.decode(UInt32.self, forKey: .threadCount)
        self.argon2idVerson = try container.decode(UInt32.self, forKey: .argon2idVerson)
    }

    internal init(from coreData : CD_DB_HeaderKeyParameters) {
        self.init(
            iterationsCount: UInt32(coreData.iterationsCount),
            keyLength: UInt32(coreData.keyLength),
            memoryLimit: UInt32(coreData.memoryLimit),
            laneCount: UInt32(coreData.laneCount),
            threadCount: UInt32(coreData.threadCount),
            argon2idVerson: UInt32(coreData.argon2idVersion)
        )
    }
}

/// The Header for an encrypted Database containing the
/// important information about the Database
internal struct DB_Header : Codable, Hashable {

    /// Whether this safe can be unlocked using biometrics
    internal var allowBiometrics : Bool

    /// The Timeout to lock the database after (in seconds)
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

    /// The database key in its encrrypted form
    internal var key : Data

    /// The key parameters used for key derivation of this database
    internal var keyParameters : DB_HeaderKeyParameters

    /// The database version scheme
    internal var version : DatabaseVersioningScheme

    /// The Path where to store the Database on
    /// the System or Cloud
    internal var path : URL?


    internal init(
        allowBiometrics : Bool,
        biometricsTimeout : Int64,
        encryption : Cryptography.Encryption,
        storageType : Storage.StorageType,
        salt : Data,
        keyParams : DB_HeaderKeyParameters,
        key : Data,
        path : URL? = nil,
        version : DatabaseVersioningScheme
    ) {
        self.allowBiometrics = allowBiometrics
        self.biometricsTimeout = biometricsTimeout
        self.encryption = encryption
        self.storageType = storageType
        self.salt = salt
        self.keyParameters = keyParams
        self.key = key
        self.version = version
    }

    internal init(from coreData : CD_DB_Header) throws {
        self.init(
            allowBiometrics: coreData.allowBiometrics,
            biometricsTimeout: coreData.biometricsTimeout,
            encryption: Cryptography.Encryption(rawValue: coreData.encryption!)!,
            storageType: Storage.StorageType(rawValue: coreData.storageType!)!,
            salt: coreData.salt!,
            keyParams: DB_HeaderKeyParameters(from: coreData.keyParams!),
            key: coreData.key!,
            path: coreData.path,
            version: try DatabaseVersioningScheme(from: coreData.version)
        )
    }

    // Decrypting Header from provided Devoder
    internal init(from decoder: Decoder) throws {
        let container : KeyedDecodingContainer = try decoder.container(keyedBy: HeaderCodingKeys.self)
        self.init(
            allowBiometrics: try container.decode(Bool.self, forKey: .allowBiometrics),
            biometricsTimeout: try container.decode(Int64.self, forKey: .biometricsTimeout),
            encryption: Cryptography.Encryption(rawValue: try container.decode(String.self, forKey: .encryption))!,
            storageType: Storage.StorageType(rawValue: try container.decode(String.self, forKey: .storageType))!,
            salt: try container.decode(Data.self, forKey: .salt),
            keyParams: try container.decode(DB_HeaderKeyParameters.self, forKey: .keyParams),
            key: try container.decode(Data.self, forKey: .key),
            path: try container.decode(URL?.self, forKey: .path),
            version: try DatabaseVersioningScheme(from: try container.decode(String.self, forKey: .version))
        )
    }


    /// Coding Keys for encoding Header to Encoder
    private enum HeaderCodingKeys: CodingKey {
        case allowBiometrics
        case biometricsTimeout
        case encryption
        case storageType
        case salt
        case keyParams
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
        try container.encode(keyParameters, forKey: .keyParams)
        try container.encode(key, forKey: .key)
        try container.encode(path, forKey: .path)
        try container.encode(version.stringRepresentation, forKey: .version)
    }

    static func == (lhs: DB_Header, rhs: DB_Header) -> Bool {
        return lhs.allowBiometrics == rhs.allowBiometrics &&
        lhs.biometricsTimeout == rhs.biometricsTimeout &&
        lhs.encryption == rhs.encryption &&
        lhs.storageType == rhs.storageType &&
        lhs.salt == rhs.salt &&
        lhs.keyParameters == rhs.keyParameters &&
        lhs.key == rhs.key &&
        lhs.path == rhs.path && // TODO: should path really be a part of equality?
        lhs.version == rhs.version // TODO: should version be a part of equality?
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(allowBiometrics)
        hasher.combine(biometricsTimeout)
        hasher.combine(encryption)
        hasher.combine(storageType)
        hasher.combine(salt)
        hasher.combine(keyParameters)
        hasher.combine(key) // TODO: should key be a part of the hash?
        hasher.combine(path)
        hasher.combine(version)
    }

    /// A preview header to use in previews and tests.
    /// The salt is still dynamically generated every time
    internal static let previewHeader : DB_Header = DB_Header(
        allowBiometrics: true,
        biometricsTimeout: 500000,
        encryption: .AES256,
        storageType: .CoreData,
        salt: try! PasswordGenerator.generateSalt(),
        keyParams: DB_HeaderKeyParameters.previewParams,
        key: try! PasswordGenerator.generateSalt(),
        path: URL(string: "/"),
        version: DatabaseVersioningScheme.previewDatabaseVersioningScheme
    )
}
