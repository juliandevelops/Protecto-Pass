//
//  DocumentInfo.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 08.09.24.
//

import SwiftUI

internal struct DocumentInfo: View {
    
    internal var document : DB_Document
    
    var body: some View {
        List {
            Section("General") {
                ListTile(name: "Name", data: document.name)
            }
            Section("File") {
                ListTile(name: "Type", data: document.type)
            }
            Section("Timeline") {
                ListTile(name: "Created", date: document.createdDate)
                ListTile(name: "Last Edited", date: document.lastEditedDate)
                ListTile(name: "Last accessed", date: document.lastAccessedDate)
            }
        }
    }
}

#Preview {
    DocumentInfo(
        document: DB_Document(
            document: Data(),
            type: "txt",
            name: "Test Document",
            createdDate: Date.now,
            lastEditedDate: Date.now,
            lastAccessedDate: Date.now,
            id: UUID(),
            tags: []
        )
    )
}
