//
//  AddDB_Overview.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddDB_Config.swift on 31.05.23.
//
//  Renamed by Julian Schumacher to AddDB_Overview.swift on 31.05.23.
//

import CryptoKit
import SwiftUI

/// The Overview Screen of the creation process
/// displaying all your Data and providing further
/// configuration options
internal struct AddDB_Overview: View {
    
    /// The View Context to interact with the CoreData System
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The Creation wrapper for this process
    @EnvironmentObject private var creationWrapper : DB_CreationWrapper
    
    /// The Controller for the Navigation
    @EnvironmentObject private var navigationController : AddDB_Navigation
    
    /// The Encryption Algorithm to encrypt the Database
    @State private var encryption : Cryptography.Encryption = .AES256
    
    /// The Type of Storage used to store this Database
    @State private var storage : Storage.StorageType = .CoreData

    // TODO: make iterations and key length user custom
    @State private var iterations : Int64 = 500000

    @State private var keyLength : Int32 = 32

    /// Whether the password is shown or not
    @State private var passwordShown : Bool = false
    
    /// When set to true, displays an alert with an Error Message, because
    /// something went wrong when saving the Database
    @State private var errSavingPresented : Bool = false

    @State private var path : URL? = nil

    @State private var selectorPresented : Bool = false
    
    var body: some View {
        List {
            Section("General Data") {
                ListTile(name: "Name", data: creationWrapper.name)
                ListTile(name: "Description", data: creationWrapper.description.isEmpty ? "No Description provided" : creationWrapper.description)
            }
            Section {
                ListTile(
                    name: "Password",
                    data: passwordShown ? creationWrapper.password : PasswordGenerator.generateFakePassword(count: creationWrapper.password.count),
                    // Not really needed, still entered to tell the System whats going on
                    textContentType: .password
                ) {
                    withAnimation {
                        passwordShown.toggle()
                    }
                }
            } header: {
                Text("Password")
            } footer: {
                Text("Tap to \(passwordShown ? "Hide" : "Show")")
            }
            Section {
                Picker("Encryption", selection: $encryption) {
                    ForEach(Cryptography.Encryption.allCases) {
                        e in
                        Text(e.rawValue)
                    }
                }
//                Picker("Storage", selection: $storage.animation()) {
//                    ForEach(Storage.StorageType.allCases) {
//                        s in
//                        Text(s.rawValue)
//                    }
//                }
                if storage == .File {
                    Button {
                        selectorPresented.toggle()
                    } label: {
                        Label(path != nil ? path!.relativePath : "Path", systemImage: path != nil ? "folder" : "questionmark.folder")
                    }
                    .fileImporter(
                        isPresented: $selectorPresented,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: false
                    ) { path = try! $0.get().first }
                }
            } header: {
                Text("Further Configuration")
            } footer: {
                Text("These data can be altered to furthermore configure your database.")
            }
        }
        .alert("Error Saving", isPresented: $errSavingPresented) {
            
        } message: {
            Text("An error occurred while saving the Database, please try again.")
        }
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    done()
                }
            }
        }
    }
    
    /// Function executed when the User pressed the Done Button
    /// This Methods creates a Database and generates all the data
    /// that isn't entered by the User
    private func done() -> Void {
        // TODO: these three lines as well as the data in the creation Wrapper may be pointless
        // They are still entered, in case the creation process will expand one day
        creationWrapper.encryption = encryption
        creationWrapper.storageType = storage
        creationWrapper.path = path
        let salt = PasswordGenerator.generateSalt()
        do {
            navigationController.db = Database(
                name: creationWrapper.name,
                description: creationWrapper.description,
                folders: [],
                entries: [],
                images: [],
                videos: [],
                iconName: creationWrapper.iconName,
                documents: [],
                created: Date.now,
                lastEdited: Date.now,
                header: DB_Header(
                    encryption: creationWrapper.encryption,
                    storageType: creationWrapper.storageType,
                    salt: salt,
                    iterationsCount: iterations,
                    keyLength: keyLength,
                    path: creationWrapper.path
                ),
                key: PasswordGenerator.generateKey(),
                derivedKey: try PasswordGenerator.deriveKey(
                    password: creationWrapper.password,
                    salt: salt,
                    iterationsCount: iterations,
                    keyLength: UInt32(keyLength)
                ),
                // TODO: change
                allowBiometrics: true,
                id: UUID()
            )
        } catch {
            errSavingPresented.toggle()
        }
        do {
            try Storage.storeDatabase(navigationController.db!, context: viewContext, superID: navigationController.db!.id)
            navigationController.openDatabaseToHome.toggle()
        } catch {
            errSavingPresented.toggle()
        }
    }
}

internal struct AddDB_Overview_Previews: PreviewProvider {
    
    /// The Wrapper for this preview
    @StateObject private static var creationWrapperPreview : DB_CreationWrapper = DB_CreationWrapper()
    
    static var previews: some View {
        AddDB_Overview()
            .environmentObject(creationWrapperPreview)
    }
}
