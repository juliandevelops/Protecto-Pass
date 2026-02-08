//
//  ME_ContentViewDocumentSection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.09.24.
//

import SwiftUI

internal struct ME_ContentViewDocumentSection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    internal init(
        dataStructure: ME_DataStructure<String, Date, Folder, Entry, LoadableResource>,
        errSavingPresented : Binding<Bool>,
        addDocPresented : Binding<Bool>
    ) {
        self.dataStructure = dataStructure
        self.errSavingPresented = errSavingPresented
        self.addDocPresented = addDocPresented
    }
    
    @State private var selectedDocument: DB_Document?
    
    /// All the documents shown and stored in this view
    @State private var documents : [DB_Document] = []
    
    /// Whether or not the sheet displaying a Document is shown
    @State private var documentShown : Bool = false
    
    @State private var documentDeletionConfirmationShown : Bool = false
    
    @State private var errDeletionShown : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the document
    @State private var errLoadingDocumentPresented : Bool = false
    
    private var errSavingPresented : Binding<Bool>
    
    private var addDocPresented : Binding<Bool>
    
    /// Displays an alert displaying an error while loading resources
    @State private var errLoadingResourcesShown : Bool = false
    
    /// Loads documents and stores them in the corresponding variables
    private func loadResources() -> Void {
        var documentIDs : [UUID] = []
        dataStructure.documents.forEach({ documentIDs.append($0.id) })
        do {
            documents = try Storage.loadDocuments(db, ids: documentIDs, context: context)
        } catch {
            errLoadingResourcesShown.toggle()
        }
    }
    
    var body: some View {
        Section("Documents") {
            if !documents.isEmpty {
                ForEach(documents) {
                    document in
                    Button {
                        selectedDocument = document
                        if document.canBeViewed() {
                            documentShown.toggle()
                        }
                    } label: {
                        Label(document.name, systemImage: "doc")
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedDocument = document
                            documentDeletionConfirmationShown.toggle()
                        } label: {
                            Label("Delete Document", systemImage: "trash")
                        }
                    }
                    .alert("Error loading Document", isPresented: $errLoadingDocumentPresented) {
                    } message: {
                        Text("There's been an error while trying to load this document")
                    }
                    .alert("Delete Document?", isPresented: $documentDeletionConfirmationShown) {
                        Button("Continue", role: .destructive) {
                            let loadableResource : LoadableResource = dataStructure.documents.first(where: { $0.id == selectedDocument!.id })!
                            do {
                                documents.removeAll(where: { $0.id == selectedDocument!.id })
                                dataStructure.documents.removeAll(where: { $0.id == selectedDocument!.id })
                                try Storage.deleteDocument(id: selectedDocument!.id, in: db, with: context)
                            } catch {
                                documents.append(selectedDocument!)
                                dataStructure.documents.append(loadableResource)
                                errDeletionShown.toggle()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            documentDeletionConfirmationShown.toggle()
                        }
                    } message: {
                        Text("This Document will be deleted\nThis action is irreversible")
                    }
                    .alert("Error deleting Folder", isPresented: $errDeletionShown) {
                    } message: {
                        Text("There's been an error deleting the selected Folder")
                    }
                    .sheet(isPresented: $documentShown) {
                        DocumentDetails(document: $selectedDocument, delete: $documentDeletionConfirmationShown)
                    }
                }
            } else {
                Text("No Documents found")
            }
        }
        .onAppear {
            loadResources()
        }
        .alert("Error loading resources", isPresented: $errLoadingResourcesShown) {
        } message: {
            Text("There's been an error while trying to load the resources from the file system")
        }
        .fileImporter(
            isPresented: addDocPresented,
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
                            onSuperID: dataStructure.id
                        )
                    } catch is DocumentLoadingError {
                        errLoadingDocumentPresented.toggle()
                    } catch is DocumentSavingError {
                        errSavingPresented.wrappedValue.toggle()
                    }
                }
            }
        )
    }
}

#Preview {
    
    @Previewable @State var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource> = Database.previewDB
    
    @Previewable @State var errSavingPresented : Bool = false
    
    @Previewable @State var addDocPresented : Bool = false
    
    ME_ContentViewDocumentSection(
        dataStructure: dataStructure,
        errSavingPresented: $errSavingPresented,
        addDocPresented: $addDocPresented
    )
}
