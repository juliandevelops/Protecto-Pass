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
    
    /// Controls the navigation flow, only necessary if this represents a Database
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// The Database used to store the complete Database Object itself when data is added to it
    @EnvironmentObject private var db : Database
    
    
    internal init(_ dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>) {
        self.dataStructure = dataStructure
    }
    
    /// The Data Structure which is displayed in this View
    @State private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    /* SELECTED OBJECT VARIABLES */
    
    /// The entry selected to present details to
    @State private var selectedEntry : Entry?
    
    
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
    
    @State private var entryDelete : Bool = false
    
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
                    .environmentObject(db)
//                ME_ContentViewFolderSection(dataStructure: dataStructure, folderDelete: $folderDelete)
//                    .environmentObject(db)
//                ME_ContentViewImageSection(
//                    dataStructure: dataStructure,
//                    metrics: metrics,
//                    errSavingPresented: $errSavingPresented,
//                    audioVisualItemsToAdd: $audioVisualItemsSelected,
//                    addImagePresented: $addImagePresented
//                )
//                .environmentObject(db)
                ME_ContentViewDocumentSection(
                    dataStructure: dataStructure,
                    errSavingPresented: $errSavingPresented,
                    addDocPresented: $addDocPresented
                )
                .environmentObject(db)
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
                        navigationController.db = nil
                        withAnimation {
                            navigationController.openDatabaseToHome.toggle()
                        }
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
                    if dataStructure is Folder {
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
