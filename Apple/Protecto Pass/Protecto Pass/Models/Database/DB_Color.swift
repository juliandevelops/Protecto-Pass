//
//  DB_Color.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 09.02.26.
//

import Foundation

// Possible way to encode colors: https://nilcoalescing.com/blog/EncodeAndDecodeSwiftUIColor/

/// Encryptable and savable color type used in this App.
internal class General_DB_Color<NumberType> : Hashable, Codable where NumberType: Hashable & Codable & Equatable {

    /// The red partion of this color (In the RGB version of the color)
    internal var red : NumberType

    /// The green partition of this color (RGB)
    internal var green : NumberType

    /// The blue partition of this color (RGB)
    internal var blue : NumberType

    /// The alpha part of the RGBA Color.
    /// This is equal to transparency or opacity
    internal var alpha : NumberType

    internal init(red: NumberType, green: NumberType, blue: NumberType, alpha: NumberType) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    internal required convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodingKeys.self)
        self.init(
            red: try container.decode(NumberType.self, forKey: .red),
            green: try container.decode(NumberType.self, forKey: .green),
            blue: try container.decode(NumberType.self, forKey: .blue),
            alpha: try container.decode(NumberType.self, forKey: .alpha)
        )
    }

    /// Coding Keys to encode and decode this color
    private enum ColorCodingKeys : CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: ColorCodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(blue, forKey: .blue)
    }

    static func == (lhs: General_DB_Color<NumberType>, rhs: General_DB_Color<NumberType>) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue && lhs.alpha == rhs.alpha
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
    }
}

/// The decrypted version of this color.
/// This can be used to represent the color in the UI
internal final class DB_Color : General_DB_Color<Int> {}

/// Encrypted version of this color.
/// No information can be concluded from the encrypted color as all parameters are encrypted independingly
/// from one another.
internal final class Encrypted_DB_Color : General_DB_Color<Data> {

    /// The identifier for the red partition of this color for the core data compositie type dictionary
    private static let CD_COMPOSITIVE_RED_IDENTIIFER : String = "red"

    /// The identifier for the green partition of this color for the core data compositie type dictionary
    private static let CD_COMPOSITIVE_GREEN_IDENTIIFER : String = "green"

    /// The identifier for the blue partition of this color for the core data compositie type dictionary
    private static let CD_COMPOSITIVE_BLUE_IDENTIIFER : String = "blue"

    /// The identifier for the alpha partition of this color for the core data compositie type dictionary
    private static let CD_COMPOSITIVE_ALPHA_IDENTIFIER : String = "alpha"


    internal convenience init(from coreData : [String : Any]?) throws {
        guard let cd = coreData else { throw DatabaseError.invalidColorScheme }
        guard let parsedRed = cd[Encrypted_DB_Color.CD_COMPOSITIVE_RED_IDENTIIFER] as? Data,
              let parsedGreen = cd[Encrypted_DB_Color.CD_COMPOSITIVE_GREEN_IDENTIIFER] as? Data,
              let parsedBlue = cd[Encrypted_DB_Color.CD_COMPOSITIVE_BLUE_IDENTIIFER] as? Data,
              let parsedAlpha = cd[Encrypted_DB_Color.CD_COMPOSITIVE_ALPHA_IDENTIFIER] as? Data
        else {
            throw DatabaseError.invalidColorScheme
        }
        self.init(
            red: parsedRed,
            green: parsedGreen,
            blue: parsedBlue,
            alpha: parsedAlpha
        )
    }

    /// This color object as dictionary.
    /// This is used to store this color inside a core data compositive type
    internal var coreDataCompositiveTypeRepresentation : [String : Any] {
        [
            Encrypted_DB_Color.CD_COMPOSITIVE_RED_IDENTIIFER : red,
            Encrypted_DB_Color.CD_COMPOSITIVE_GREEN_IDENTIIFER : green,
            Encrypted_DB_Color.CD_COMPOSITIVE_BLUE_IDENTIIFER : blue,
            Encrypted_DB_Color.CD_COMPOSITIVE_ALPHA_IDENTIFIER : alpha
        ]
    }
}
