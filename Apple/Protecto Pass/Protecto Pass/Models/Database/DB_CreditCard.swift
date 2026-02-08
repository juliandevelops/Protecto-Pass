//
//  DB_CreditCard.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.02.26.
//

import Foundation

/// General credit card type.
/// This represents a credit card in this app. It represents an abstract class as this is never stored directly
///
/// # Params
/// DE: DAte
/// DA: Icon Name Data
/// DO: Documents type
/// CDAS: Card Data String
/// CDAN: Card Data Number
internal class GeneralDB_CreditCard<CDAS, CDAN, DE, DA, DO> : DB_NativeType<DE, DA, DO>  {

    internal var cardNumber : CDAS

    internal var cvv_cvc : CDAN

    internal var expirationDate : DE
}

internal class DB_CreditCard : GeneralDB_CreditCard<String, Int16, Date, String, DB_LoadableResource>, DecryptedDataStructure {

}

internal class Encrypted_DB_CreditCard : GeneralDB_CreditCard<Data, Data, Data, Data, Encrypted_DB_LoadableRessource>, EncryptedDataStructure {

}
