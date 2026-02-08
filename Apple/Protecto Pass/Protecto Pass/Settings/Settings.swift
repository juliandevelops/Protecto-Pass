//
//  Settings.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 07.09.23.
//

import CoreData
import Foundation
import SwiftUI

/// Enum with a case for every Settings value with the stored identifier
/// String
internal enum Settings : String, RawRepresentable {
    
    // Root View
    case largeScreen = "large_screen_preference"
    
    case compactMode = "compact_mode_preference"
    
    case appVersion = "app_version_preference"
    
    case buildVersion = "build_version_preference"
    
    case resetApp = "reset_app_preference"
    
    
    // iCloud View
    case syncPathToiCloud = "sync_paths_preference"
    
    case syncSettingsToiCloud = "sync_settings_preference"
    
    case deleteiCloudData = "delete_icloud_data_preference"
    
    // Background Settings
    case lastUpdated = "settings_last_updated"
}

/// Struct to manage Settings, load and update them
/// out of this App in the Systems Settings App.
internal struct SettingsHelper {
    
    /// Whether the Settings should be synced to iCloud or not
    private static var iCloudSettings : Bool = true
    
    /// Whether the Paths of the databases should be synced to iCloud or not
    private static var iCloudPaths : Bool = true

    private static var largeScreen : Bool = false
    
    private static var compactMode : Bool = false
    
    
    /// Initialized the Settings, creates the Preferences Object in
    /// iCloud if needed
    internal static func loadiCloud(with context : NSManagedObjectContext) throws -> Void {
        if checkiCloudReset() {
            if let appData : AppData = try context.fetch(AppData.fetchRequest()).first {
                context.delete(appData)
            }
            if let preferences : Preferences = try context.fetch(Preferences.fetchRequest()).first {
                context.delete(preferences)
            }
        } else {
            if iCloudPaths {
                if try context.fetch(AppData.fetchRequest()).first == nil {
                    // Create new App Data Object, so it's available later
                    let _ = AppData(context: context)
                }
            }
            if iCloudSettings {
                let updatedNow : Date = Date.now
                if let settingsFromiCloud : Preferences = try context.fetch(Preferences.fetchRequest()).first {
                    if try DataConverter.dataToDate(UserDefaults.standard.data(forKey: Settings.lastUpdated.rawValue)!) < settingsFromiCloud.lastUpdated! {
                        compactMode = settingsFromiCloud.compactMode
                        largeScreen = settingsFromiCloud.largeScreen
                        UserDefaults.standard.set(updatedNow, forKey: Settings.lastUpdated.rawValue)
                    } else {
                        settingsFromiCloud.compactMode = compactMode
                        settingsFromiCloud.largeScreen = largeScreen
                        settingsFromiCloud.lastUpdated = updatedNow
                    }
                    updateSettings()
                } else {
                    let preferences : Preferences = Preferences(context: context)
                    preferences.compactMode = compactMode
                    preferences.largeScreen = largeScreen
                    preferences.lastUpdated = updatedNow
                }
            }
        }
    }
    
    /// Loads all the Data to:
    /// 1. the Settings App
    /// 2. This App (returns a Dictionary of all Settings and their values)
    internal static func load(context : NSManagedObjectContext) throws -> [Settings : Bool] {
        updateVersion()
        return try loadData(context: context)
    }
    
    /// Load the current Value of the Settings
    private static func loadData(context : NSManagedObjectContext) throws -> [Settings : Bool] {
        if checkReset() {
            largeScreen = false
            compactMode = false
            iCloudSettings = true
            iCloudPaths = true
            try reset(context: context)
        } else {
            largeScreen = UserDefaults.standard.bool(forKey: Settings.largeScreen.rawValue)
            compactMode = UserDefaults.standard.bool(forKey: Settings.compactMode.rawValue)
            iCloudSettings = UserDefaults.standard.bool(forKey: Settings.syncSettingsToiCloud.rawValue)
            iCloudPaths = UserDefaults.standard.bool(forKey: Settings.syncPathToiCloud.rawValue)
        }
        return [
            .largeScreen : largeScreen,
            .compactMode : compactMode,
            .syncSettingsToiCloud : iCloudSettings,
            .syncPathToiCloud : iCloudPaths
        ]
    }
    
    /// Checks whether the "Reset App" Switch in the System Settings App
    /// has been set to true
    private static func checkReset() -> Bool {
        if UserDefaults.standard.bool(forKey: Settings.resetApp.rawValue) {
            UserDefaults.standard.set(false, forKey: Settings.resetApp.rawValue)
            return true
        } else {
            return false
        }
    }
    
    /// Checks if the "Delete Data" Switch in the iCloud Subview of the Settings
    /// App has been toggled and resets it if necessary
    private static func checkiCloudReset() -> Bool {
        if UserDefaults.standard.bool(forKey: Settings.deleteiCloudData.rawValue) {
            UserDefaults.standard.set(false, forKey: Settings.deleteiCloudData.rawValue)
            return true
        } else {
            return false
        }
    }
    
    /// Resets the App
    private static func reset(context : NSManagedObjectContext) throws -> Void {
        try Storage.clearAll(context: context)
    }
    
    /// Update the Version and Build Number of this App in the Settings
    /// App of the System
    private static func updateVersion() -> Void {
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleShortVersionString"], forKey: Settings.appVersion.rawValue)
        UserDefaults.standard.set(Bundle.main.infoDictionary!["CFBundleVersion"], forKey: Settings.buildVersion.rawValue)
    }
    
    /// Updates all the Settings with those from iCloud
    private static func updateSettings() -> Void {
        UserDefaults.standard.set(compactMode, forKey: Settings.compactMode.rawValue)
        UserDefaults.standard.setValue(largeScreen, forKey: Settings.largeScreen.rawValue)
    }
}

/// Key for the Large Screen Setting injected into the Environment
private struct LargeScreenSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = false
}

/// Key for the Compact Mode Setting injected into the Environment
private struct CompactModeSettingsKey : EnvironmentKey {
    static var defaultValue: Bool = false
}

/// Defines both, the compact Mode and large Screen variable for the SwiftUI
/// Environment
internal extension EnvironmentValues {
    var compactMode : Bool {
        get { self[CompactModeSettingsKey.self] }
        set { self[CompactModeSettingsKey.self] = newValue }
    }
    
    var largeScreen : Bool {
        get { self[LargeScreenSettingsKey.self] }
        set { self[LargeScreenSettingsKey.self] = newValue }
    }
    
    func appendPath(_ path : URL) -> Void {
        AppDataHelper.appendPath(path)
    }
}
