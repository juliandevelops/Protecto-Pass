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
                ListTile(name: "Created", date: document.created)
                ListTile(name: "Last Edited", date: document.lastEdited)
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
            created: Date.now,
            lastEdited: Date.now,
            id: UUID()
        )
    )
}
