//
//  EditEntry.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddEntry.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to EditEntry.swift on 26.08.23.
//

import SwiftUI
import UniformTypeIdentifiers

/// View to add a new Entry with all it's data.
/// This entry is stored in the current folder
internal struct EditEntry: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var vaultSession : VaultSession

    /// The Database to store this Object in
    @EnvironmentObject private var db : Database
    
    /// The Folder or Database to store this Entry in
    @State internal var superID : UUID
    
    /// The Title of this entry
    @State private var title : String = ""
    
    /// The Username of this Entry.
    /// This typically is a Name, not a link
    @State private var username : String = ""
    
    /// The Password stored in this Entry.
    /// This is the most important part
    @State private var password : String = ""
    
    /// The URL to where the entry is connected to
    @State private var url : String = ""
    
    /// Some details to this Entry
    @State private var details : String = ""

    @State private var documents : [DB_Document] = []
    
    /// Whether or not an error has appeared storing the Database
    @State private var errStoring : Bool = false
    
    /// The name of the icon representing this Entry
    @State private var iconName : String = "doc"
    
    /// Whether or not the icon Chooser is shown
    @State private var iconChooserShown : Bool = false
    
    @State private var filePickerPresented : Bool = false
    
    internal init(entry : DB_Entry, superID: UUID) {
        self.title = entry.title
        // TODO: update entry username and password here
        self.username = "entry.encryptedUsername"
        self.password = "entry.encryptedPassword"
        self.url = entry.url?.absoluteString ?? ""
        self.details = entry.details
        self.iconName = entry.iconName
        self.superID = superID
    }
    
    internal init(superID: UUID) {
        self.superID = superID
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Representation") {
                    Button {
                        iconChooserShown.toggle()
                    } label: {
                        Label("Icon", systemImage: iconName)
                    }
                    .foregroundStyle(.primary)
                    .sheet(isPresented: $iconChooserShown) {
                        IconChooser(iconName: $iconName, type: .entry)
                    }
                }
                Section("Information") {
                    TextField("Title", text: $title)
                }
                Section("Credentials") {
                    TextField("Username", text: $username)
                    TextField("Password", text: $password)
                }
                Section("Connection") {
                    TextField("URL", text: $url)
                }
                Section("Documents") {
                    if documents.isEmpty {
                        Text("No documents added yet")
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(documents) {
                            document in
                            Text(document.name)
                        }
                    }
                    Button {
                        filePickerPresented.toggle()
                    } label: {
                        Label("Add Document", systemImage: "plus")
                    }
                }
                .foregroundStyle(.primary)
                .fileImporter(
                    isPresented: $filePickerPresented,
                    allowedContentTypes: [.item],
                    allowsMultipleSelection: true,
                    onCompletion: {
                        result in
                        Task {
                            do {
                                try FileImportHandler.handleDocumentPickerInput(
                                    result: result,
                                    documents: $documents,
                                    storeIn: db,
                                    context: context,
                                    onSuperID: superID
                                )
                            } catch is DocumentLoadingError {
                                
                            } catch is DocumentSavingError {
                                
                            }
                        }
                    }
                )
            }
            .alert("Error saving", isPresented: $errStoring) {
                Button("Cancel", role: .cancel) {}
                Button("Try again") { save() }
            } message: {
                Text("An Error occurred when trying to save the data.\nPlease try again")
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarBackButtonHidden()
            .toolbarRole(.editor)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
                    .disabled(title.isEmpty || username.isEmpty || password.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Saves the data and dismisses this View
    private func save() -> Void {
        var localDocuments : [DB_LoadableResource] = []
        for doc in documents {
            localDocuments.append(
                DB_LoadableResource(
                    id: doc.id,
                    name: doc.name,
                    thumbnailData: DataConverter.stringToData("doc")
                )
            )
        }
        var newElements : [DatabaseContent<Date, UUID, DB_Tag>] = []
        newElements.append(contentsOf: documents)
        newElements.append(
            DB_Entry(
                title: title,
                encryptedUsername: Data(), // TODO: update username and password in new entry
                encryptedPassword: Data(),
                url: URL(string: url),
                details: details,
                iconName: iconName,
                documents: localDocuments,
                createdDate: Date.now,
                lastEditedDate: Date.now,
                lastAccessedDate: Date.now,
                id: UUID(),
                tags: [] // TODO: update tags
            )
        )
        do {
            try vaultSession.store(context: context)
//            try Storage.storeDatabase(
//                db,
//                context: context,
//                newElements: newElements,
//                superID: superID
//            )
            dismiss()
        } catch {
            errStoring.toggle()
        }
    }
}

internal struct EditEntry_Previews: PreviewProvider {
    
    @StateObject private static var database : Database = Database.previewDB
    
    static var previews: some View {
        EditEntry(superID: database.id)
            .environmentObject(database)
        
    }
}
