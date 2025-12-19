//
//  UnlockDB.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 18.04.23.
//

import SwiftUI

/// The View to unlock a specific Database
internal struct UnlockDB: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var navigationSheet : AddDB_Navigation
    
    /// The Encrypted Database the User wants to unlock
    @Binding internal var db : EncryptedDatabase
    
    /// The unlocked Database
    @State private var unlockedDB : Database? = nil
    
    /// The Password entered by the User with which
    /// the App tries to unlock the Database
    @State private var password : String = ""
    
    /// When an error occurs while trying to unlock the Database,
    /// toggle this to show the error message
    @State private var errDecryptingPresented : Bool = false
    
    @State private var informationPopoverPresented : Bool = false
    
    @State private var dbContentCounter : DatabaseContentCounter?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Section {
                    Section {
                        Text("Encrypted with \(db.header.encryption.rawValue)")
                        Text("Stored in \(db.header.storageType.rawValue)")
                    } header: {
                        Text("General")
                            .font(.headline)
                    }
                    Divider()
                    Section {
                        contentSection()
                    } header: {
                        HStack {
                            Text("Content")
                                .font(.headline)
                            Button {
                                informationPopoverPresented.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .renderingMode(.original)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .foregroundStyle(.primary)
                            .popover(isPresented: $informationPopoverPresented, arrowEdge: .bottom) {
                                NavigationView {
                                    Text("These information only contain documents added soley as documents. Attachments to entries are not respected in these information.")
                                        .padding(.all, 50)
                                        .navigationTitle("Content Information")
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                                 
                            }
                        }
                    }
                    Divider()
                } header: {
                    Text("Information")
                        .font(.title)
                    Divider()
                } footer: {
                    Text(db.description)
                }
                PasswordField(title: "Enter your Password...", text: $password)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.roundedBorder)
            }
            .onAppear {
                dbContentCounter = DatabaseContentCounter(for: db)
            }
            .navigationTitle("Unlock \(db.name)")
            .navigationBarTitleDisplayMode(.automatic)
            .padding(20)
            .alert("Error Unlock Database", isPresented: $errDecryptingPresented) {
            } message: {
                Text("An Error occurred while trying to unlock the Database\nMaybe the entered Password is incorrect.\nIf This Error remains, the Database may be corrupt.")
            }
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Unlock") {
                        tryUnlocking()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        if let counter = dbContentCounter {
            let foldersCount = counter.getFoldersCount()
            let entriesCount = counter.getEntriesCount()
            let documentsCount = counter.getDocumentsCount()
            let imagesCount = counter.getImagesCount()
//            Text("• \(foldersCount) \(foldersCount == 1 ? "Folder" : "Folders")")
            Text("• \(entriesCount) \(entriesCount == 1 ? "Entry" : "Entries")")
            Text("• \(documentsCount) \(documentsCount == 1 ? "Document" : "Documents")")
//            Text("• \(imagesCount) \(imagesCount == 1 ? "Image" : "Images")")
        } else {
            EmptyView()
        }
    }
    
    /// Try to unlock the Database with the provided password
    private func tryUnlocking() -> Void {
        do {
            var decrypter = Decrypter.configure(for: db, with: password)
            let localDatabase : Database = try decrypter.decrypt()
            unlockedDB = localDatabase
            navigationSheet.db = unlockedDB
            dismiss()
            navigationSheet.openDatabaseToHome.toggle()
        } catch {
            errDecryptingPresented.toggle()
        }
    }
    
    
}

/// The Preview for this Database Unlock Screen
internal struct UnlockDB_Previews: PreviewProvider {
    
    @State private static var db : EncryptedDatabase = EncryptedDatabase.previewDB
    static var previews: some View {
        UnlockDB(db: $db)
    }
}
