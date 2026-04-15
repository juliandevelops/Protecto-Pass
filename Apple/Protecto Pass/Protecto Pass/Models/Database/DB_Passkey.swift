//
//  Passkey.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.02.26.
//

import Foundation

// TODO: udpate passkey implementation

internal class DB_Passkey : DecryptedDataStructure {
    static func == (lhs: DB_Passkey, rhs: DB_Passkey) -> Bool {
        // TODO: update == func
        return false
    }

    func hash(into hasher: inout Hasher) {
        // TODO: implement hash
    }
}

internal class Encrypted_DB_Passkey : EncryptedDataStructure {

}

//internal class General_DB_Passkey<DateType, DataType, DocumentType, IDType, TagType> : DB_NativeType<DateTpye, DataType, DocumentType, IDType, TagType> {
//
//    internal init(
//        iconName: DataType,
//        documents : [DocumentType],
//        details : DataType,
//        createdDate: DateType,
//        lastEditedDate: DateType,
//        lastAccessedDate: DateType,
//        id: IDType,
//        tags: [TagType]
//    ) {
//        super.init(
//            iconName: DataType,
//            documents : [DocumentType],
//            details : DataType,
//            createdDate: createdDate,
//            lastEditedDate: lastEditedDate,
//            lastAccessedDate: lastAccessedDate,
//            id: id,
//            tags: tags
//        )
//    }
//}
//
//internal final class DB_Passkey : General_DB_Passkey, DecryptedDataStructure {}
//
//internal final class Encrypted_DB_Passkey : General_DB_Passkey, EncryptedDataStructure {}
