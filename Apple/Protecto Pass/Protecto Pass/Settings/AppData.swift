//
//  AppData.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.10.23.
//

import CoreData
import Foundation

private enum AppDataKeys : String, RawRepresentable {
    case paths = "app_data_paths"
}

internal struct AppDataHelper {
    
    internal private(set) static var paths : [URL] = []
    
    private static var cdAppData : AppData? = nil
    
    internal static func appendPath(_ path : URL) -> Void {
        paths.append(path)
        let localPaths : [String] = paths.map { url in url.absoluteString }
//        let cdPath : DB_Path = DB_Path(context: context)
//        cdPath.path = path
//        cdAppData!.addToPaths(cdPath)
        UserDefaults.standard.set(localPaths, forKey: AppDataKeys.paths.rawValue)
    }
    
    internal static func load() -> Void {
        let pathsAsString : [String] = UserDefaults.standard.stringArray(forKey: AppDataKeys.paths.rawValue)!
        for path in pathsAsString {
            paths.append(URL(string: path)!)
        }
    }
    
    internal static func loadiCloud(with context : NSManagedObjectContext) throws -> Void {
        if let localAppData = try context.fetch(AppData.fetchRequest()).first {
            cdAppData = localAppData
            var localPaths : [URL] = []
            for path in cdAppData!.paths! {
                localPaths.append((path as! DB_Path).path!)
            }
            paths = localPaths
        } else {
            cdAppData = AppData(context: context)
        }
    }
}
