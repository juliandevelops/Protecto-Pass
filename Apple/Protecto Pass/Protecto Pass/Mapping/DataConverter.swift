//
//  DataConverter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.08.23.
//

import Foundation
import UIKit

internal struct DataConverter {
    
    /* STRING <-> DATA */

    /// Converts the passed String to Data (Bytes)
    internal static func stringToData(_ string : String) -> Data {
        return string.data(using: .utf8)!
    }

    /// Converts the passed Data to a String. If the Data are nil, an empty String is returned
    internal static func dataToString(_ data : Data?) -> String {
        guard data != nil else {
            return ""
        }
        return String(data: data!, encoding: .utf8)!
    }
    
    
    /* STRING <-> DATE */

    /// Converts a String to a Date
    internal static func stringToDate(_ string : String) throws -> Date {
        return try Date(string, strategy: .iso8601)
    }

    /// Converts a Data to a String
    internal static func dateToString(_ date : Date) -> String {
        return date.ISO8601Format(.iso8601)
    }
    
    
    /* DATA <-> DATE */

    /// Converts a Date to Data (Bytes)
    internal static func dateToData(_ date : Date) -> Data {
        return stringToData(dateToString(date))
    }

    /// Converts Data (Bytes) to a Date
    internal static func dataToDate(_ data : Data) throws -> Date {
        return try stringToDate(dataToString(data))
    }
    
    
    /* IMAGE -> DATA */

    /// Converts an Image to Bytes
    internal static func imageToData(_ image : DB_Image) throws -> Data {
        return image.image.jpegData(compressionQuality: CGFloat(image.quality))!
    }
    
    
    /* DATA <-> NUMBER */

    /// Converts a Double to Bytes
    internal static func doubleToData(_ double : Double) -> Data {
        return stringToData(String(double))
    }

    /// Converts Bytes (Data) to a Double
    internal static func dataToDouble(_ data : Data) -> Double {
        return Double(dataToString(data))!
    }



    /* DATA <-> UUID */

    internal static func dataToUUID(_ data: Data) -> UUID {
        return UUID(uuidString: dataToString(data))!
    }


    internal static func uuidToData(_ uuid: UUID) -> Data {
        return stringToData(uuid.uuidString)
    }


    /* DATA <-> INT */

// TODO: update data int converter
    internal static func dataToInt(_ data: Data) -> Int {
        return Int(dataToString(data))!
    }

    internal static func intToData(_ int: Int) -> Data {
        return stringToData(String(int))
    }
}
