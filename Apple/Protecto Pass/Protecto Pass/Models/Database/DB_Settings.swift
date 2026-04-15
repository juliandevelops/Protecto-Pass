//
//  DB_Settings.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 09.02.26.
//

import Foundation

internal class General_DB_Settings {
    
}

internal final class DB_Settings : General_DB_Settings {

}

internal final class Encrypted_DB_Settings : General_DB_Settings {

}

// MARK: DB Settings Menu Item Add

/// Enum for the different Items in the Add Item Menu
internal enum MenuItemAdd {
    case entry
    case folder
    case document
    case imageAndVideo
    case creditCard
    case passkey
    case note
    case token
    case tag
    case asymmetricKey
}

/// A single item in the Add Item Menu.
/// This class contains the item as well as the current state (active or not).
/// Active means it's shown in the Add Items menu inside the app while inactive means it's not shown.
/// This can be toggled per database
internal class General_DB_Settings_MenuItemAdd<ToggleType, NameType> {

    /// The name of the item to add.
    /// This will be one of `MenuItemAdd`
    internal var name : NameType

    /// Whether this item is shown or not
    internal var active : ToggleType


    internal init(name: NameType, active: ToggleType) {
        self.name = name
        self.active = active
    }
}

/// The decrypted settings item for items in the add item menu
internal final class DB_Settings_MenuItemAdd : General_DB_Settings_MenuItemAdd<Bool, MenuItemAdd>, DecryptedDataStructure {

    static func == (lhs: DB_Settings_MenuItemAdd, rhs: DB_Settings_MenuItemAdd) -> Bool {
        return lhs.name == rhs.name && lhs.active == rhs.active
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(active)
    }
}

/// The encrypted settings item for the MenuItemAdd setting
internal final class Encrypted_DB_Settings_MenuItemAdd : General_DB_Settings_MenuItemAdd<Data, Data>, EncryptedDataStructure {

    private enum DB_Settings_MenuItemAdd_CodingKeys: CodingKey {
        case name
        case active
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DB_Settings_MenuItemAdd_CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(active, forKey: .active)
    }

    internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DB_Settings_MenuItemAdd_CodingKeys.self)
        self.init(
            name: try container.decode(Data.self, forKey: .name),
            active: try container.decode(Data.self, forKey: .active)
        )
    }
}
