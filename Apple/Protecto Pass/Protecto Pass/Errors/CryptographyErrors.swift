//
//  CryptographyErrors.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.02.26.
//

import Foundation

internal enum CryptoError : Error {
    case errDerivation
    case errUnlocking
    case errLocking
    case unknownEncryption
    case errRandomBytesGeneration
}
