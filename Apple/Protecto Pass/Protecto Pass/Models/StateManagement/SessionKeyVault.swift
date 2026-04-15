//
//  SessionKeyVault.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.03.26.
//

import CryptoKit
import Foundation

/// Storage point of the masterKey in an active session.
internal class SessionKeyVault {

    /// Only living copy of the masterkey.
    /// Never access or pass this key directly.
    /// Only use `withKey` function to execute any operation requiring a key.
    private let masterKey : SecureKeyBytes

    internal init(masterKeyDataBytes : SecureKeyBytes) {
        // Create only living copy of masterkey
        self.masterKey = masterKeyDataBytes
    }

    internal func withKey<Result>(_ action : (SymmetricKey) throws -> Result) rethrows -> Result {
        return try masterKey.withUnsafeBytes {
            buffer in
            let key = SymmetricKey(
                data: Data(
                    bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress)!,
                    count: buffer.count,
                    deallocator: .none
                )
            )
            return try action(key)
        }
    }

    deinit {
        // Session Key is deallocated within SecureKeyBytes deinit
    }
}
