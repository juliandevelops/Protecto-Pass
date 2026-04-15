//
//  ME_ContentView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.08.23.
//

import SwiftUI
import PhotosUI

internal struct ME_ContentView : View {
    
    /* ENVIRONMENT VARIABLES */
    
    @Environment(\.managedObjectContext) private var context

    /// Whether the User activated the large Screen preference or not
    @Environment(\.largeScreen) private var largeScreen : Bool
    
    // Environment Objects
    @EnvironmentObject private var vaultSession : VaultSession

    /// The Database used to store the complete Database Object itself when data is added to it
    @EnvironmentObject private var db : Database
    
    
    internal init(_ dataStructure :  DB_ME_DataStructure<
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
    ) {
        self.dataStructure = dataStructure
    }
    
    /// The Data Structure which is displayed in this View
    @State private var dataStructure :  DB_ME_DataStructure<
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

    /* SELECTED OBJECT VARIABLES */
    
    /// The entry selected to present details to
    @State private var selectedEntry : DB_Entry?

    
    /* SHEET CONTROL VARIABLES */
    // Adding
    
    @State private var addEntryPresented : Bool = false
    
    /// Whether or not the sheet to add a folder is presented
    @State private var addFolderPresented : Bool = false
    
    /// Whether or not the sheet to add an image is presented
    @State private var addImagePresented : Bool = false
    
    /// Whether or not the sheet to add a document is presented
    @State private var addDocPresented : Bool = false
    
    /// The Photos and videos selected to add to the Password Safe
    @State private var audioVisualItemsSelected : [PhotosPickerItem] = []
    
    
    
    // Details
    
    /// Whether or not the details sheet is presented
    @State private var detailsPresented : Bool = false
    
    /// Set to true in order to present the details sheet for the `selectedEntry`
    @State private var entryDetailsPresented : Bool = false
    
    /* ERROR ALERT CONTROL VARIABLES */
    
    // Saving
    
    /// Presents an alert stating an error has appeared in saving the database when set to true
    @State private var errSavingPresented : Bool = false
    
    // Deleting

    /// Whether to delete an entry or not
    @State private var entryDelete : Bool = false

    /// Whether to delete a folder or not
    @State private var folderDelete : Bool = false

    
    var body: some View {
        GeometryReader {
            metrics in
            List {
                if largeScreen {
                    Section {
                    } header: {
                        Image(systemName: dataStructure.iconName)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
                ME_ContentViewEntrySection(
                    dataStructure: dataStructure,
                    selectedEntry: $selectedEntry,
                    entryDetailsPresented: $entryDetailsPresented,
                    entryDelete: $entryDelete
                )
                .environmentObject(vaultSession)
                ME_ContentViewFolderSection(
                    dataStructure: dataStructure,
                    folderDelete: $folderDelete
                )
                .environmentObject(vaultSession)
                // Not implemented in current version
                // TODO: migration to vaultSession instead of database still has to be done in the following sections
//                ME_ContentViewImageSection(
//                    dataStructure: dataStructure,
//                    metrics: metrics,
//                    errSavingPresented: $errSavingPresented,
//                    audioVisualItemsToAdd: $audioVisualItemsSelected,
//                    addImagePresented: $addImagePresented
//                )
//                ME_ContentViewDocumentSection(
//                    dataStructure: dataStructure,
//                    errSavingPresented: $errSavingPresented,
//                    addDocPresented: $addDocPresented
//                )
            }
        }
        // Shows "Home" when the Data Structure is a Database, otherwise shows the title of the data structure. While the data structure is nil, such as while the app is loading, it showns "Loading..."
        .navigationTitle(dataStructure is Database ? "Home" : dataStructure.name)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            if dataStructure is Database {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        // TODO: lock database -> zero out and delete all local data as far as possible => go to welcome view
                    } label: {
                        Image(systemName: "lock")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        addEntryPresented.toggle()
                    } label: {
                        Label("Add Entry", systemImage: "doc")
                    }
//                    Button {
//                        addFolderPresented.toggle()
//                    } label: {
//                        Label("Add Folder", systemImage: "folder")
//                    }
//                    Button {
//                        addImagePresented.toggle()
//                    } label: {
//                        Label("Add Images & Videos", systemImage: "photo")
//                    }
                    Button {
                        addDocPresented.toggle()
                    } label: {
                        Label("Add Document", systemImage: "doc.text")
                    }
                    Divider()
                    Button {
                        detailsPresented.toggle()
                    } label: {
                        Label("Details", systemImage: "info.circle")
                    }
                    Divider()
                    Button {
                        // TODO: Activate Edit mode
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    if dataStructure is DB_Folder {
                        Divider()
                        Button(role: .destructive) {
                            // TODO: deleting folder from here does nothing
                            folderDelete.toggle()
                        } label: {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        // Detail sheets
        .sheet(isPresented: $detailsPresented) {
            Me_Details(me: dataStructure)
        }
        .sheet(isPresented: $entryDetailsPresented) {
            EntryDetails(entry: $selectedEntry, entryDeleted: $entryDelete)
        }
        // Edit / Add sheets
        .sheet(isPresented: $addEntryPresented) {
            EditEntry(superID: dataStructure.id)
                .environmentObject(db)
        }
        .sheet(isPresented: $addFolderPresented) {
            EditFolder(storeIn: dataStructure.id)
                .environmentObject(db)
        }
        .photosPicker(
            isPresented: $addImagePresented,
            selection: $audioVisualItemsSelected,
            maxSelectionCount: 100,
            selectionBehavior: .continuousAndOrdered,
            matching: .any(of: [.images, .videos]),
            preferredItemEncoding: .automatic
        )
        // loading error alerts
        .alert("Error saving Database", isPresented: $errSavingPresented) {
        } message: {
            Text("An Error arised saving the Database to the file system")
        }
    }
}


/// Preview
internal struct ME_ContentView_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
            .environmentObject(db)
    }
}

internal struct ME_ContentViewLargeScreen_Previews: PreviewProvider {
    
    @StateObject private static var db : Database = Database.previewDB
    
    static var previews: some View {
        ME_ContentView(db)
            .environmentObject(db)
            .environment(\.largeScreen, true)
    }
}
