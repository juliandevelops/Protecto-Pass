//
//  DatabaseErrors.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.03.26.
//

import Foundation

internal enum DatabaseError : Error {
    case invalidVersion
    case invalidColorScheme
    case nilData
    case conversionError
}
