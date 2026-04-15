//
//  PasswordGenerator.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.05.23.
//

import CryptoKit
import Foundation

/// Struct to generate random and secure Passwords
internal struct PasswordGenerator {
    
    /// Enum containing the different parts of characters
    /// a password can contain.
    ///
    /// Build your password content with a list of these.
    internal enum PasswordContent {
        case upperCaseLetters
        case lowerCaseLetters
        case digits
        case symbols
        
        /// Returns all the possible content of a password
        internal static func getAll() -> Set<PasswordContent> {
            return [
                .upperCaseLetters,
                .lowerCaseLetters,
                .digits,
                .symbols
            ]
        }
    }

    private static func generateRandomSecureBytes(count : Int) throws -> Data {
        var bytes = [Int8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            throw CryptoError.errRandomBytesGeneration
        }
        return Data(bytes: bytes, count: count)
    }

    /// Generates a secure salt for the password.
    /// The size is 64 bits and it contains every possible content
    /// Also, the salt does not contains ':' or  ';'
    internal static func generateSalt() throws -> Data {
        return try generateRandomSecureBytes(count: 32)
    }

    internal static func generateSymmetricKey() throws -> Data {
        return try generateRandomSecureBytes(count: 256)
    }

    /// Generates a random and secure password with the
    /// specified length and content characters
    internal static func generatePassword(
        length : Int,
        characters : Set<PasswordContent>
    ) -> String {
        let pg : PasswordGenerator = PasswordGenerator(
            length: length,
            characters: characters
        )
        return pg.generatePassword()
    }
    
    /// All the upper case letters in the english alpahbet
    private static let upperCaseLetters : String =  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    /// All the lower case letters in the english alpahbet
    private static let lowerCaseLetter : String = "abcdefghijklmnopqrstuvwxyz"

    /// All the digits in the english alpahbet
    private static let digits : String = "0123456789"

    /// All the symbols this Apps support to include in the password
    /// generation process
    private static let symbols : String = "^°!\"§$%&/()=?`´\\*+#'-_.:,;<>“[]|{}¿'„€@~"

    /// The length of the password
    private let length : Int
    
    /// All the characters in the passwords content
    private let characters : Set<PasswordContent>
    
    /// Returns a String containing all the elements the User specified for this
    /// Password Generator
    private func getContent() -> String {
        var content : String = ""
        for c in characters {
            switch c {
            case .upperCaseLetters:
                content.append(PasswordGenerator.upperCaseLetters)
            case .lowerCaseLetters:
                content.append(PasswordGenerator.lowerCaseLetter)
            case .digits:
                content.append(PasswordGenerator.digits)
            case .symbols:
                content.append(PasswordGenerator.symbols)
            }
        }
        return content
    }
    
    /// Generates a random and secure password with
    /// the specified length and content characters of the
    /// previously specified generator
    internal func generatePassword() -> String {
        // Discussion: https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
        // Solution: https://stackoverflow.com/a/26845710
        // TODO: is this a secure random function?
        return String((0..<length).map { _ in getContent().randomElement()! })
    }
    
    /// Generates a string containing of only "•" as long as the original password
    internal static func generateFakePassword(count : Int) -> String {
        // TODO: is count safe to use?
        return String(
            (0 ..< count).map {
                _ in
                "•"
            }
        )
    }
}
