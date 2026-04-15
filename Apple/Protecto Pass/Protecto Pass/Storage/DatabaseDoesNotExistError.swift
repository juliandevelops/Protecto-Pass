//
//  DatabaseCache.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as DatabaseCache.swift on 27.08.23.
//
//  Renamed by Julian Schumacher to Caches.swift on 09.03.24
//

import Foundation

/// Error thrown when the Cache tries to access a Database
/// that does not exist, at least not in this particular Cache
internal struct DatabaseDoesNotExistError : Error {}
