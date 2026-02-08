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
    
    /// Generates a secure salt for the password.
    /// The size is 64 bits and it contains every possible content
    /// Also, the salt does not contains ':' or  ';'
    internal static func generateSalt() throws -> Data {
        var bytes = [Int8](repeating: 0, count: 64)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            throw CryptoError.errRandomVytesGeneration
        }
        return Data(bytes: bytes, count: 64)
//        var salt : String = generatePassword(
//            length: 64,
//            characters: PasswordContent.getAll()
//        )
//        salt.replace(":", with: ".")
//        salt.replace(";", with: "_")
//        return salt
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
    private let upperCaseLetters : String =  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    /// All the lower case letters in the english alpahbet
    private let lowerCaseLetter : String = "abcdefghijklmnopqrstuvwxyz"
    
    /// All the digits in the english alpahbet
    private let digits : String = "0123456789"
    
    /// All the symbols this Apps support to include in the password
    /// generation process
    private let symbols : String = "^°!\"§$%&/()=?`´\\*+#'-_.:,;<>“[]|{}¿'„€@~"
    
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
                content.append(upperCaseLetters)
            case .lowerCaseLetters:
                content.append(lowerCaseLetter)
            case .digits:
                content.append(digits)
            case .symbols:
                content.append(symbols)
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

    internal static func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
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
