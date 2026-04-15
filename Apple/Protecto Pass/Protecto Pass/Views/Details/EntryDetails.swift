//
//  EntryDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 28.07.23.
//

import SwiftUI

internal struct EntryDetails: View {
    
    @EnvironmentObject private var db : Database
    
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding internal var entry : DB_Entry?

    @Binding internal var entryDeleted : Bool
    
    @State private var passwordShown : Bool = false
    
    @State private var documents : [DB_Document] = []
    
    @State private var documentShown : Bool = false
    
    @State private var selectedDocument : DB_Document?
    
    @State private var documentDeleted : Bool = false
    
    @State private var errSavingPresented : Bool = false
    
    var body: some View {
        NavigationStack {
//            List {
//                Section("Credentials") {
//                    Group {
//                        Menu {
//                            Button {
//                                print("Test")
//                            } label: {
//                                Text("TODO: REPLACE ME")
//                            }
//                        } label: {
//                            Text("TODO: REPLACE ME")
//                        }
//                    }
//                    Group {
////                        Menu {
////                            Button {
////                                print("Test")
////                                // https://stackoverflow.com/a/63006562
////                                UIPasteboard.general.setItems(
////                                    [
////                                        [UIPasteboard.typeAutomatic: entry!.password]
////                                    ],
////                                    options: [
////                                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(30)
////                                    ]
////                                )
////                            } label: {
////                                Label("Copy Username", systemImage: "list.clipboard")
////                            }
////                        } label: {
////                       Text("TODO: REPLACE ME")
//////                            ListTile(name: "Username", data: entry!.username, textContentType: .username)
////                        }
////                        Menu {
////                            Button {
//////                                UIPasteboard.general.string = entry!.password
////                            } label: {
////                                Label("Copy Password", systemImage: "list.clipboard")
////                            }
////                            Button {
////                                withAnimation {
////                                    passwordShown.toggle()
////                                }
////                            } label: {
////                                Label("\(passwordShown ? "Hide" : "Show") Password", systemImage: passwordShown ? "eye.slash" : "eye")
////                            }
////                        } label: {
////                            ListTile(
////                                name: "Password",
////                                data: passwordShown ? String(describing: entry!.encryptedPassword) : PasswordGenerator
////                                    .generateFakePassword(count: entry!.encryptedPassword.count),
////                                textContentType: .password
////                            )
////                        }
//                    }
//                    .foregroundStyle(.primary)
//                }
//                Section("Connection") {
//                    if let link = entry!.url {
//                        Menu {
//                            Button {
//                                UIApplication.shared.open(link)
//                            } label: {
//                                Label("Open Link", systemImage: "safari")
//                            }
//                        } label: {
//                            ListTile(name: "Link", data: link.host()!)
//                        }
//                        .foregroundStyle(.primary)
//                    }
//                }
//                Section("Information") {
//                    Group {
//                        Text("Details")
//                        Text(!entry!.details.isEmpty ? entry!.details : "No details given")
//                            .foregroundStyle(.gray)
//                    }
//                }
//                Section("Documents") {
//                    if !documents.isEmpty {
//                        ForEach(documents) {
//                            doc in
//                            Button {
//                                selectedDocument = doc
//                                documentShown.toggle()
//                            } label: {
//                                Label(doc.name, systemImage: "doc")
//                            }
//                        }
//                        .sheet(isPresented: $documentShown) {
//                            DocumentDetails(document: $selectedDocument, delete: $documentDeleted)
//                        }
//                        .onChange(of: documentDeleted) {
//                            Task {
//                                do {
//                                    try Storage.deleteDocument(id: selectedDocument!.id, in: db, with: context)
//                                    documents.removeAll(where: { $0.id == selectedDocument!.id })
//                                    documentDeleted = false
//                                } catch {
//                                    errSavingPresented.toggle()
//                                }
//                            }
//                        }
//                    } else {
//                        Text("No documents added yet")
//                            .foregroundStyle(.gray)
//                    }
//                }
//                Section("Timeline") {
//                    ListTile(name: "Last edited", date: entry!.lastEdited)
//                    ListTile(name: "Created", date: entry!.created)
//                }
//            }
//            .navigationTitle(entry!.title)
//            .navigationBarTitleDisplayMode(.automatic)
//            .toolbarRole(.automatic)
//            .toolbar(.automatic, for: .automatic)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel", role: .cancel) {
//                        dismiss()
//                    }
//                }
//                // TODO: add actions
//                ToolbarItem(placement: .primaryAction) {
//                    Menu {
//                        Button {
//                            
//                        } label: {
//                            Label("Edit", systemImage: "pencil")
//                        }
//                        Button {
//                            
//                        } label: {
//                            Label("Move", systemImage: "folder")
//                        }
//                        Divider()
//                        Button(role: .destructive) {
//                            entryDeleted.toggle()
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                    }
//                }
//            }
//        }
//        .onAppear {
//            var ids : [UUID] = []
//            for doc in documents {
//                ids.append(doc.id)
//            }
//            Task {
//                do {
//                    documents = try Storage.loadDocuments(db, ids: ids, context: context)
//                } catch {
//                    // TODO: handle error
//                }
//            }
        }
    }
}


#Preview {
    
    @Previewable @State var entry : DB_Entry? = DB_Entry.previewEntry

    @Previewable @StateObject var database : Database = Database.previewDB
    
    @Previewable @State var entryDelete : Bool = false
    
    EntryDetails(entry: $entry, entryDeleted: $entryDelete)
        .environmentObject(database)
}
