//
//  ME_ContentViewFolderSection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.09.24.
//

import SwiftUI

internal struct ME_ContentViewFolderSection: View {

    @Environment(\.managedObjectContext) private var context

    @EnvironmentObject private var vaultSession: VaultSession

    @ObservedObject private var dataStructure:
        DB_ME_DataStructure<
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

    internal init(
        dataStructure: DB_ME_DataStructure<
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
        >,
        folderDelete: Binding<Bool>
    ) {
        self.dataStructure = dataStructure
        self.folderDeletionConfiramtionShown = folderDelete
    }

    @State private var selectedFolder: DB_Folder?

    private var folderDeletionConfiramtionShown: Binding<Bool>

    @State private var errDeletionShown: Bool = false

    var body: some View {
        Section("Folder") {
            if !dataStructure.folders.isEmpty {
                ForEach(dataStructure.folders) {
                    folder in
                    NavigationLink {
                        ME_ContentView(folder)
                            .environmentObject(vaultSession)
                    } label: {
                        Label(folder.name, systemImage: folder.iconName)
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedFolder = folder
                            folderDeletionConfiramtionShown.wrappedValue.toggle()
                        } label: {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                }
            } else {
                Text("No Folders found")
            }
        }
        .alert("Delete Folder?", isPresented: folderDeletionConfiramtionShown) {
            Button("Continue", role: .destructive) {
                do {
                    dataStructure.folders.removeAll(where: { $0.id == selectedFolder!.id })
                    try vaultSession.store(context: context)
//                    try Storage
//                        .storeDatabase(vaultSession.database, context: context, superID: dataStructure.id)
                } catch {
                    dataStructure.folders.append(selectedFolder!)
                    errDeletionShown.toggle()
                }
            }
            Button("Cancel", role: .cancel) {
                folderDeletionConfiramtionShown.wrappedValue.toggle()
            }
        } message: {
            Text("This Folder and all it's content will be deleted\nThis action is irreversible")
        }
        .alert("Error deleting Folder", isPresented: $errDeletionShown) {
        } message: {
            Text("There's been an error deleting the selected Folder")
        }
    }
}

#Preview {

    @Previewable @State var dataStructure:
        DB_ME_DataStructure<
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
        > = Database.previewDB

    @Previewable @State var folderDelete: Bool = false

    //    List {
    //        ME_ContentViewFolderSection(dataStructure: dataStructure, folderDelete: $folderDelete)
    //    }
}
