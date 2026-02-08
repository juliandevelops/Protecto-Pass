//
//  Cryptography.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.05.23.
//

import CryptoKit
import Foundation

internal struct Cryptography {
    
    /// An Enum representing the
    /// supported encryptions of this App
    internal enum Encryption : String, RawRepresentable, CaseIterable, Identifiable {
        var id: Self { self }
        
        /// Using AES 256 Bit for the Encryption and Decryption
        case AES256
        
        /// Using ChaCha20-Poly1305 for the Encryption and Decryption
        case ChaChaPoly
    }
    
    /// Converts the specified String to Bytes, but before hashes it using SHA-256
    internal static func sha256HashBytes(_ string : String) -> Data {
        let hashed : SHA256Digest = SHA256.hash(data: DataConverter.stringToData(string))
        return hashed.withUnsafeBytes {
            return Data(Array($0))
        }
    }
}
