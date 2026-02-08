//
//  DatabaseContentCounter.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 29.08.24.
//

import Foundation

internal struct DatabaseContentCounter {
    
    private var isEncrypted : Bool
    
    private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>?
    
    private var db : EncryptedDatabase?
    
    internal init(for dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>) {
        self.isEncrypted = false
        self.dataStructure = dataStructure
        self.db = nil
    }
    
    internal init(for db : EncryptedDatabase) {
        self.isEncrypted = true
        self.db = db
        self.dataStructure = nil
    }
    
    
    // Entries Count
    
    internal func getEntriesCount() -> Int {
        var count : Int
        if isEncrypted {
            count = db!.entries.count
            for folder in db!.folders {
                count += getEntriesCountInFolder(folder)
            }
        } else {
            count = dataStructure!.entries.count
            for folder in dataStructure!.folders {
                count += getEntriesCountInFolder(folder)
            }
        }
        return count
    }
    
    private func getEntriesCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count = folder.entries.count
        for folder in folder.folders {
            count += getEntriesCountInFolder(folder)
        }
        return count
    }
    
    private func getEntriesCountInFolder(_ folder : Folder) -> Int {
        var count = folder.entries.count
        for folder in folder.folders {
            count += getEntriesCountInFolder(folder)
        }
        return count
    }
    
    
    // Folders Count
    
    internal func getFoldersCount() -> Int {
        var count : Int
        if isEncrypted {
            count = db!.folders.count
            for folder in db!.folders {
                count += getFoldersCountInFolder(folder)
            }
        } else {
            count = dataStructure!.folders.count
            for folder in dataStructure!.folders {
                count += getFoldersCountInFolder(folder)
            }
        }
        return count
    }
    
    private func getFoldersCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count = folder.folders.count
        for folder in folder.folders {
            count += getFoldersCountInFolder(folder)
        }
        return count
    }
    
    private func getFoldersCountInFolder(_ folder : Folder) -> Int {
        var count = folder.folders.count
        for folder in folder.folders {
            count += getFoldersCountInFolder(folder)
        }
        return count
    }
    
    
    // Documents Count
    
    internal func getDocumentsCount() -> Int {
        var count : Int
        if isEncrypted {
            count = db!.documents.count
            for folder in db!.folders {
                count += getDocumentsCountInFolder(folder)
            }
        } else {
            count = dataStructure!.documents.count
            for folder in dataStructure!.folders {
                count += getDocumentsCountInFolder(folder)
            }
        }
        return count
    }
    
    private func getDocumentsCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count = folder.documents.count
        for folder in folder.folders {
            count += getDocumentsCountInFolder(folder)
        }
        return count
    }
    
    private func getDocumentsCountInFolder(_ folder : Folder) -> Int {
        var count = folder.documents.count
        for folder in folder.folders {
            count += getDocumentsCountInFolder(folder)
        }
        return count
    }
    
    
    // Images Count
    
    internal func getImagesCount() -> Int {
        var count : Int
        if isEncrypted {
            count = db!.images.count
            for folder in db!.folders {
                count += getImagesCountInFolder(folder)
            }
        } else {
            count = dataStructure!.images.count
            for folder in dataStructure!.folders {
                count += getImagesCountInFolder(folder)
            }
        }
        return count
    }
    
    private func getImagesCountInFolder(_ folder : EncryptedFolder) -> Int {
        var count = folder.images.count
        for folder in folder.folders {
            count += getImagesCountInFolder(folder)
        }
        return count
    }
    
    private func getImagesCountInFolder(_ folder : Folder) -> Int {
        var count = folder.images.count
        for folder in folder.folders {
            count += getImagesCountInFolder(folder)
        }
        return count
    }
}
