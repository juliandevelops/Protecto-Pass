//
//  DB_CreditCard.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.02.26.
//

import Foundation

/// General credit card type.
/// This represents a credit card in this app. It represents an abstract class as this is never stored directly
internal class GeneralDB_CreditCard<
    CardStringType,
    CardNumberType,
    DateType,
    DataType,
    DocumentType,
    IDType,
    TagType
> : DB_NativeType<DateType, DataType, DocumentType, IDType, TagType>  {

    /// The name of the card holder.
    /// This is the name that is engraved into the front of the card
    internal var cardHolderName : CardStringType

    /// The credit card number in itself.
    /// This will not be stored as parsed number.
    /// Decrypted this will be a string
    ///
    /// This field is always encrypted up to decryption on demand.
    internal var encryptedCardNumber : Data

    /// The Security Number of the card.
    /// Visa calls it CVV (Card Verification Value)
    /// while Mastercard calls it CVC (Card Verification Code).
    /// American Express uses CID (Card Identification Number)
    ///
    ///This field is always encrypted up to decryption on demand.
    internal var encryptedSecurityNumber : Data

    /// The expiration date of the credit card.
    ///
    /// This field is always encrypted up to decryption on demand.
    internal var encryptedExpirationDate : Data


    internal init(
        cardHolderName : CardStringType,
        encryptedCardNumber: Data,
        encryptedSecurityNumber: Data,
        encryptedExpirationDate: Data,
        iconName: DataType,
        documents: [DocumentType],
        details: DataType,
        createdDate: DateType,
        lastEditedDate: DateType,
        lastAccessedDate: DateType,
        id: IDType,
        tags: [TagType]
    ) {
        self.cardHolderName = cardHolderName
        self.encryptedCardNumber = encryptedCardNumber
        self.encryptedSecurityNumber = encryptedSecurityNumber
        self.encryptedExpirationDate = encryptedExpirationDate
        super.init(
            iconName: iconName,
            documents: documents,
            details: details,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }
}

internal class DB_CreditCard : GeneralDB_CreditCard<String, Int16, Date, String, DB_LoadableResource, UUID, DB_Tag>, DecryptedDataStructure {

    /// This buffer will be used to store the decrypted card number decrypted
    /// on demand.
    ///
    /// # Workflow
    ///  When viewing a creditcard, the required sensitive information will be decrypted
    ///  on demand and stored in the according buffer.
    ///  This buffer will be described by a string element in the UI.
    ///  After closing the view and not using this buffer, this buffer must be overwritten,
    ///  preferably with memset\_s (DO NOT USE memset as it can be removed by compiler optimization).
    ///  Only after overwriting this buffer the view can be closed.
    ///
    ///  ## Background Information
    ///  Overwriting this buffer does not garantuee that all data are cleared from RAM.
    ///  When displaying the number in the UI, it must be copied into a string which cannot be overwritten
    ///  or deleted by the developer.
    ///  Swifts ARC (Automativ Reference Counting) will deallocate or remove the string when not needed anymore.
    ///  This risk is accepted as the attack requires root access to memory.
    internal var decryptedCardNumber : Data

    /// This buffer will be used to store the decrypted security number after decrypting
    /// it on demand.
    ///
    /// # Workflow
    ///  When viewing a creditcard, the required sensitive information will be decrypted
    ///  on demand and stored in the according buffer.
    ///  This buffer will be described by a string element in the UI.
    ///  After closing the view and not using this buffer, this buffer must be overwritten,
    ///  preferably with memset\_s (DO NOT USE memset as it can be removed by compiler optimization).
    ///  Only after overwriting this buffer the view can be closed.
    ///
    ///  ## Background Information
    ///  Overwriting this buffer does not garantuee that all data are cleared from RAM.
    ///  When displaying the number in the UI, it must be copied into a string which cannot be overwritten
    ///  or deleted by the developer.
    ///  Swifts ARC (Automativ Reference Counting) will deallocate or remove the string when not needed anymore.
    ///  This risk is accepted as the attack requires root access to memory.
    internal var decryptedSecurityNumber : Data

    /// This buffer will be used to store the decrypted expiration Date after decrypting
    /// it on demand.
    ///
    /// # Workflow
    ///  When viewing a creditcard, the required sensitive information will be decrypted
    ///  on demand and stored in the according buffer.
    ///  This buffer will be described by a string element in the UI.
    ///  After closing the view and not using this buffer, this buffer must be overwritten,
    ///  preferably with memset\_s (DO NOT USE memset as it can be removed by compiler optimization).
    ///  Only after overwriting this buffer the view can be closed.
    ///
    ///  ## Background Information
    ///  Overwriting this buffer does not garantuee that all data are cleared from RAM.
    ///  When displaying the number in the UI, it must be copied into a string which cannot be overwritten
    ///  or deleted by the developer.
    ///  Swifts ARC (Automativ Reference Counting) will deallocate or remove the string when not needed anymore.
    ///  This risk is accepted as the attack requires root access to memory.
    internal var decryptedExpirationDate : Data

    internal override init(
        cardHolderName: String,
        encryptedCardNumber: Data,
        encryptedSecurityNumber: Data,
        encryptedExpirationDate: Data,
        iconName: String,
        documents: [DB_LoadableResource],
        details: String,
        createdDate: Date,
        lastEditedDate: Date,
        lastAccessedDate: Date,
        id: UUID,
        tags: [DB_Tag]
    ) {
        decryptedCardNumber = Data()
        decryptedSecurityNumber = Data()
        decryptedExpirationDate = Data()
        super.init(
            cardHolderName: cardHolderName,
            encryptedCardNumber: encryptedCardNumber,
            encryptedSecurityNumber: encryptedSecurityNumber,
            encryptedExpirationDate: encryptedExpirationDate,
            iconName: iconName,
            documents: documents,
            details: details,
            createdDate: createdDate,
            lastEditedDate: lastEditedDate,
            lastAccessedDate: lastAccessedDate,
            id: id,
            tags: tags
        )
    }

    static func == (lhs: DB_CreditCard, rhs: DB_CreditCard) -> Bool {
        return lhs.cardHolderName == rhs.cardHolderName &&
        lhs.encryptedCardNumber == rhs.encryptedCardNumber &&
        lhs.encryptedSecurityNumber == rhs.encryptedSecurityNumber &&
        lhs.encryptedExpirationDate == rhs.encryptedExpirationDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(cardHolderName)
        hasher.combine(encryptedCardNumber)
        hasher.combine(encryptedSecurityNumber) // TODO: should this be part of the hash?
        hasher.combine(encryptedExpirationDate)
    }
}

internal class Encrypted_DB_CreditCard : GeneralDB_CreditCard<Data, Data, Data, Data, Encrypted_DB_LoadableResource, Data, Encrypted_DB_Tag>, EncryptedDataStructure {

    private enum CreditCardCodingKeys : CodingKey {
        case cardHolerName
        case encryptedCardNumer
        case encryptedSecurityNumber
        case encryptedExpirationDate
        case iconName
        case documents
        case details
        case createdDate
        case lastEditedDate
        case lastAccessedDate
        case id
        case tags
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CreditCardCodingKeys.self)
        try container.encode(cardHolderName, forKey: .cardHolerName)
        try container.encode(encryptedCardNumber, forKey: .encryptedCardNumer)
        try container.encode(encryptedSecurityNumber, forKey: .encryptedSecurityNumber)
        try container.encode(encryptedExpirationDate, forKey: .encryptedExpirationDate)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(documents, forKey: .documents)
        try container.encode(details, forKey: .details)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastEditedDate, forKey: .lastEditedDate)
        try container.encode(lastAccessedDate, forKey: .lastAccessedDate)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
    }


    required internal convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CreditCardCodingKeys.self)
        self.init(
            cardHolderName: try container.decode(Data.self, forKey: .cardHolerName),
            encryptedCardNumber: try container.decode(Data.self, forKey: .encryptedCardNumer),
            encryptedSecurityNumber: try container.decode(Data.self, forKey: .encryptedSecurityNumber),
            encryptedExpirationDate: try container.decode(Data.self, forKey: .encryptedExpirationDate),
            iconName: try container.decode(Data.self, forKey: .iconName),
            documents: try container.decode([Encrypted_DB_LoadableResource].self, forKey: .documents),
            details: try container.decode(Data.self, forKey: .details),
            createdDate: try container.decode(Data.self, forKey: .createdDate),
            lastEditedDate: try container.decode(Data.self, forKey: .lastEditedDate),
            lastAccessedDate: try container.decode(Data.self, forKey: .lastAccessedDate),
            id: try container.decode(Data.self, forKey: .id),
            tags: try container.decode([Encrypted_DB_Tag].self, forKey: .tags)
        )
    }

    internal convenience init(from coreData : CD_CreditCard) throws {
        var localDocuments : [Encrypted_DB_LoadableResource] = []
        for document in coreData.documents! {
            localDocuments.append(Encrypted_DB_LoadableResource(from: document as! CD_LoadableResource))
        }
        var localTags : [Encrypted_DB_Tag] = []
        for tag in coreData.tags! {
            localTags.append(try Encrypted_DB_Tag(from: tag as! CD_DB_Tag))
        }
        self.init(
            cardHolderName: coreData.cardHolderName!,
            encryptedCardNumber: coreData.cardNumber!,
            encryptedSecurityNumber: coreData.securityNumber!,
            encryptedExpirationDate: coreData.expirationDate!,
            iconName: coreData.iconName!,
            documents: localDocuments,
            details: coreData.details!,
            createdDate: coreData.createdDate!,
            lastEditedDate: coreData.lastEditedDate!,
            lastAccessedDate: coreData.lastAccessedDate!,
            id: coreData.uuid!,
            tags: localTags
        )
    }
}
