//
//  Welcome.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as ContentView.swift on 01.04.23.
//
//  Renamed by Julian Schumacher to Home.swift on 18.04.23.
//
//  Renamed by Julian Schumacher to Welcome.swift on 18.04.23.
//

import SwiftUI

/// The View that is shown to the User as soon as
/// he opens the App
internal struct Welcome: View {

    /// Whether this view shall be displayed in compact mode
    @Environment(\.compactMode) private var compactMode

    /// The context to interact with Core Data
    @Environment(\.managedObjectContext) private var context
    
    /// The Object to control the navigation of and with the AddDB Sheet
    @EnvironmentObject private var navigationSheet : AddDB_Navigation
    
    /// All the Databases of the App.
    @State internal var databases : [EncryptedDatabase]
    
    /// Whether or not the unlock Database View as a sheet is shown.
    /// This does only apply to Databases already in the VIew.
    /// Databases imported from file are controlled via the unlockDBFromPathPresented Property
    @State private var unlockDBShown : Bool = false
    
    /// Whether or not the file Importer is shown
    @State private var selectorPresented : Bool = false
    
    /// The Database, stored as file, selected by the User
    /// on the File System
    @State private var dbFromPath : EncryptedDatabase?

    /// The Database that shall be unlocked.
    ///
    /// The initial value is the encrypted Database so this value cannot be nil which is required
    /// as the UnlockDB view loads while the database may be selected
    @State private var dbToUnlock : EncryptedDatabase = EncryptedDatabase.previewDB

    /// Control variable used to display an error when reading a database from a provided path failed
    @State private var errReadingDatabaseFromPathShown : Bool = false

    /// Control. variable used to display an error when the deletion of a database failed
    @State private var errDeletingDatabaseShown : Bool = false

    /// Control variable whether to show the confirmation dialog to delete a database
    @State private var deleteDatabaseShown : Bool = false
    
    var body: some View {
        NavigationStack {
            build()
                .sheet(isPresented: $unlockDBShown) {
                    UnlockDB(encryptedDatabase: $dbToUnlock)
                        .environmentObject(navigationSheet)
                }
                .sheet(isPresented: $navigationSheet.databaseAddingSheetShown) {
                    if compactMode {
                        AddDB_CompactMode()
                            .environmentObject(navigationSheet)
                    } else {
                        AddDB()
                            .environmentObject(navigationSheet)
                    }
                }
                .toolbarRole(.navigationStack)
                .toolbar(.automatic, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                navigationSheet.databaseAddingSheetShown.toggle()
                            } label: {
                                Label("Create Database", systemImage: "plus")
                            }
                            //                            Button {
                            //                                selectorPresented.toggle()
                            //                            } label: {
                            //                                Label("Open from File", systemImage: "doc")
                            //                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationTitle("Welcome")
                .navigationBarTitleDisplayMode(.automatic)
        }
    }

    /// The build method for this view
    ///
    /// - Returns: the main view for this page
    @ViewBuilder
    private func build() -> some View {
        if !databases.isEmpty {
            // Geometry Reader use with Scroll View: https://stackoverflow.com/questions/58226768/how-to-make-the-row-fill-the-screen-width-with-some-padding-using-swiftui
            // Used answer: https://stackoverflow.com/a/58230599
            GeometryReader {
                metrics in
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible())], spacing: 10) {
                        ForEach(databases) {
                            db in
                            container(for: db, width: metrics.size.width - 30)
                            
                        }
                        .padding(15)
                    }
                }
            }
        } else {
            VStack {
                Group {
                    Text("No Databases found.")
                    //                    Button("Open from File") {
                    //                        selectorPresented.toggle()
                    //                    }
                    //                    .fileImporter(
                    //                        isPresented: $selectorPresented,
                    //                        allowedContentTypes: [.folder],
                    //                        allowsMultipleSelection: false
                    //                    ) {
                    //                        let path : URL = try! $0.get().first!
                    //                        let jsonDecoder : JSONDecoder = JSONDecoder()
                    //                        do {
                    //                            dbFromPath = try jsonDecoder.decode(
                    //                                EncryptedDatabase.self,
                    //                                from: try Data(
                    //                                    contentsOf: path,
                    //                                    options: [.uncached]
                    //                                )
                    //                            )
                    //                        } catch {
                    //                            errReadingDatabaseFromPathShown.toggle()
                    //                        }
                    //                        dbToUnlock = dbFromPath!
                    //                    }
                        .alert("Error Reading DB", isPresented: $errReadingDatabaseFromPathShown) {
                        } message: {
                            Text("There's been an error while reading the Database from the File System.\nPlease try again")
                        }
                    Button("Create new one") {
                        navigationSheet.databaseAddingSheetShown.toggle()
                    }
                }.padding(2.5)
            }
        }
    }
    
    /// Builds a container for the provided database
    ///
    /// - Parameters
    ///     - db: The encrypted database to build the container for
    ///     - width: the width for this container
    ///
    /// - Returns: the rendered view
    @ViewBuilder
    private func container(for db : EncryptedDatabase, width : CGFloat) -> some View {
        Button {
            dbToUnlock = db
            unlockDBShown.toggle()
        } label: {
            VStack {
                Image(systemName: db.iconName)
                Text(db.name)
                    .font(.headline)
                Text(db.details)
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
            }
            // - 150 because horizontal padding is 75
            .frame(width: abs(width - 150))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 75)
        .padding(.vertical, 100)
        .background(Color.gray)
        .cornerRadius(15)
        .alert("Delete Database?", isPresented: $deleteDatabaseShown) {
            Button("Continue", role: .destructive) {
                do {
                    databases.removeAll(where: { $0.id == db.id })
                    try Storage.deleteDatabase(id: db.id, with: context)
                } catch {
                    databases.append(db)
                    errDeletingDatabaseShown.toggle()
                }
            }
            Button("Cancel", role: .cancel) {
                deleteDatabaseShown.toggle()
            }
        } message: {
            Text("The Database and all the items in it will be deleted\nThis action is irreversible")
        }
        .contextMenu {
            Button(role: .destructive) {
                deleteDatabaseShown.toggle()
            } label: {
                Label("Delete Database", systemImage: "trash")
            }
        }
        .alert("Error deleting DB", isPresented: $errDeletingDatabaseShown) {
        } message: {
            Text("There's been an error while trying to delete the Database from the File System.\nPlease try again")
        }
    }
}

/// Preview Provider for an empty welcome view.
/// This previews a view with no databases in the app.
internal struct EmptyWelcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: []
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, false)
    }
}

/// Preview provider with databases added.
internal struct FilledWelcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: [
                EncryptedDatabase.previewDB,
            ]
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, false)
    }
}

/// Preview provider without any databases and the compact Mode activated
internal struct EmptyWelcomeCompact_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: []
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, true)
    }
}

/// Preview provider with databases added and the compact mode active
internal struct FilledWelcomeCompact_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(
            databases: [
                EncryptedDatabase.previewDB,
            ]
        )
        .environmentObject(AddDB_Navigation())
        .environment(\.compactMode, true)
    }
}
