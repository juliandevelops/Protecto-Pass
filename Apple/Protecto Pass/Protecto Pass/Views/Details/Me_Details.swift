//
//  ME_Details.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as FolderDetails.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to ME_Details.swift on 22.08.23.
//

import SwiftUI

internal struct Me_Details: View {

    @Environment(\.dismiss) private var dismiss
    
    internal let me : DB_ME_DataStructure<
        String,
        Date,
        DB_Folder,
        DB_Entry,
        DB_LoadableResource,
        DB_CreditCard,
        DB_Note,
        DB_Passkey,
        UUID,
        DB_Tag
    >

    @State private var dbContentCounter : DatabaseContentCounter?
    
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    ListTile(name: "Name", data: me.name)
                    if me.details.isEmpty {
                        ListTile(name: "Description", data: "No Description provided")
                    } else {
                        Group {
                            Text("Description")
                            Text(me.details)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section {
                    if let counter = dbContentCounter {
                        let foldersCount = counter.getFoldersCount()
                        let entriesCount = counter.getEntriesCount()
                        let documentsCount = counter.getDocumentsCount()
                        let imagesCount = counter.getImagesCount()
//                        Text("\(foldersCount) \(foldersCount == 1 ? "Folder" : "Folders")")
                        Text("\(entriesCount) \(entriesCount == 1 ? "Entry" : "Entries")")
                        Text("\(documentsCount) \(documentsCount == 1 ? "Document" : "Documents")")
//                        Text("\(imagesCount) \(imagesCount == 1 ? "Image" : "Images")")
                    }
                } header: {
                    Text("Content")
                } footer: {
                    Text("These information only contain documents added soley as documents. Attachments to entries are not respected in these information.")
                }
                Section("Timeline") {
                    ListTile(name: "Created", date: me.createdDate)
                    ListTile(name: "Last edited", date: me.lastEditedDate)
                    ListTile(name: "Last accessed:", date: me.lastAccessedDate)
                }
            }
            .onAppear {
                dbContentCounter = DatabaseContentCounter(for: me)
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

internal struct ME_Details_Previews: PreviewProvider {
    static var previews: some View {
        Me_Details(me: DB_Folder.previewFolder)
    }
}
