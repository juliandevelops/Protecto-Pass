//
//  SecureKeyBytes.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.03.26.
//

import Foundation

/// A storage class for securly storing key bytes and other secrets.
/// This class handles the memory directly and zeroes the memory
/// before deallocating the memory when not used anymore.
internal final class SecureKeyBytes : Equatable {

    /// Pointer to the memory location this SecureKeyBytes instance handles
    private let pointer : UnsafeMutableRawPointer

    /// Count of the bytes in this Byte Struct
    internal let count : Int

    internal init(count : Int) {
        self.pointer = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
        self.count = count
    }

    internal convenience init(copying bytes : Data, count : Int) throws {
        self.init(count: count)
        try write(bytes)
    }

    /// Write data to the memory location
    internal func write(_ data : Data) throws -> Void {
        guard count >= data.count else {
            throw MemoryErrors.invalidSize
        }
        data.copyBytes(to: pointer.assumingMemoryBound(to: UInt8.self), count: data.count)
    }

    internal func withUnsafeBytes<Result>(_ body : (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
        return try body(UnsafeRawBufferPointer(start: pointer, count: count))
    }


    internal func zeroOut() {
        memset_s(pointer, count, 0, count)
    }

    /// Compares the provided string with the content of the buffer
    internal func compareWithString(_ string : String) throws -> Bool {
        try withUnsafeBytes {
            buffer in
            let stringAsKeyBytes = try SecureKeyBytes(
                copying: DataConverter.stringToData(string),
                count: string.count
            )
            let result : Bool = stringAsKeyBytes == self
            stringAsKeyBytes.zeroOut()
            return result
        }
    }

    static func == (lhs: SecureKeyBytes, rhs: SecureKeyBytes) -> Bool {
        lhs.withUnsafeBytes {
            left in
            rhs.withUnsafeBytes {
                right in
                guard left.count == right.count else {
                    return false
                }
                return memcmp(
                    UnsafeMutableRawPointer(mutating: left.baseAddress!),
                    UnsafeMutableRawPointer(mutating: right.baseAddress!),
                    left.count
                ) == 0
            }
        }
    }

    static func generateNewSymmetricKey() throws -> SecureKeyBytes {
        return try SecureKeyBytes(
            copying: try PasswordGenerator.generateSymmetricKey(),
            count: 256
        )
    }

    deinit {
        // Zero out memory
        zeroOut()
        // deallocate memory
        pointer.deallocate()
    }
}
