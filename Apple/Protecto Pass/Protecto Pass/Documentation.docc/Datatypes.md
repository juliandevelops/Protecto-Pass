# Datatypes

A summary over all data types used in Protecto Pass

## Overview

This Page shows an overview over all data types and the inheritance of them.

The following diagram shows a quick overview without going into details. The following sections will explain the different data types in more detail.

````mermaid
mindmap DatabaseContent
    DB_Document
    DB_Image
    DB_Video
    DB_Note
    DB_NativeType
        DB_Passkey
        DB_CreditCard
        DB_Entry
        DB_ME_DataStructure
            Database
            DB_Folder
````

## Class Diagram

```mermaid
classDiagram
    class DB_Tag {
        + name : DataType
        + color : ColorType
    }

    class DatabaseContent {
        <<abstract>>
        + id : IDType
        + lastEdited : DateType
        + created : DateType
        + lastAccessed : DateType
    }
    DatabaseContent --|> DB_Document
    DatabaseContent --|> DB_Image
    DatabaseContent --|> DB_Video
    DatabaseContent --|> DB_Note
    DatabaseContent --|> DB_NativeType
    DatabaseContent o-- DB_Tag

    class DB_NativeType {
        <<abstract>>
        + iconName : DataType
        + notes : DataType
    }
    DB_NativeType --|> DB_CreditCard
    DB_NativeType --|> DB_Passkey
    DB_NativeType --|> DB_Entry
    DB_NativeType --|> DB_ME_DataStructure
    DB_NativeType --|> DB_AsymmetricKeyPair
    DB_NativeType --|> DB_Token

    class DB_ME_DataStructure {
        <<abstract>>
        + dataDescription : DataType
        + name : DataType
    }
    DB_ME_DataStructure --|> Database
    DB_ME_DataStructure --|> DB_Folder
    DB_ME_DataStructure o-- DB_CreditCard
    DB_ME_DataStructure o-- DB_Entry
    DB_ME_DataStructure o-- DB_Folder
    DB_ME_DataStructure o-- DB_LoadableResource
    DB_ME_DataStructure o-- DB_Passkey

    class DB_CreditCard {
        + cardNumber : DataType
        + cardHolderName : DataType
        + expirationDate : DataType
        + securityNumber : DataType
    }

    class DB_Document {
        + documentData : DataType
        + name : DataType
        + type : DataType
    }

    class DB_Image {
        + compressionQuality : DataType
        + imageData : DataType
        + name : DataType
    }

    class DB_Video {
        + videoData : DataType
        + name : DataType
    }
    class DB_Note {
        + content : DataType
    }

    class DB_Passkey {
    }

    class DB_Entry {

    }

    class DB_Folder {

    }

    class Database {

    }

    class DB_AsymmetricKeyPair {

    }

    class DB_Header {

    }

    class DB_Token {

    }
```
