//
//  ME_ContentViewEntrySection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 22.09.24.
//

import SwiftUI

internal struct ME_ContentViewEntrySection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    @ObservedObject private var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>
    
    private var selectedEntry : Binding<Entry?>
    
    private var entryDetailsPresented : Binding<Bool>
    
    internal init(
        dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource>,
        selectedEntry : Binding<Entry?>,
        entryDetailsPresented : Binding<Bool>,
        entryDelete : Binding<Bool>
    ) {
        self.dataStructure = dataStructure
        self.selectedEntry = selectedEntry
        self.entryDetailsPresented = entryDetailsPresented
        self.entryDeletionConfirmationShown = entryDelete
    }
    
    private var entryDeletionConfirmationShown : Binding<Bool>
    
    @State private var errDeletionShown : Bool = false
    
    var body: some View {
        Section("Entries") {
            if !dataStructure.entries.isEmpty {
                ForEach(dataStructure.entries) {
                    entry in
                    Button {
                        selectedEntry.wrappedValue = entry
                        entryDetailsPresented.wrappedValue.toggle()
                    } label: {
                        Label(entry.title, systemImage: entry.iconName)
                    }
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedEntry.wrappedValue = entry
                            entryDeletionConfirmationShown.wrappedValue.toggle()
                        } label: {
                            Label("Delete Entry", systemImage: "trash")
                        }
                    }
                    .alert("Delete Entry?", isPresented: entryDeletionConfirmationShown) {
                        Button("Continue", role: .destructive) {
                            do {
                                dataStructure.entries.removeAll(where: { $0.id == selectedEntry.wrappedValue!.id })
                                try Storage.storeDatabase(db, context: context, superID: dataStructure.id)
                            } catch {
                                dataStructure.entries.append(selectedEntry.wrappedValue!)
                                errDeletionShown.toggle()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            entryDeletionConfirmationShown.wrappedValue.toggle()
                        }
                    } message: {
                        Text("This Entry and all its connected documents will be deleted\nThis action is irreversible")
                    }
                    .alert("Error deleting Entry", isPresented: $errDeletionShown) {
                    } message: {
                        Text("There's been an error deleting the selected Entry")
                    }
                }
            } else {
                Text("No Entries found")
            }
        }
    }
}

#Preview {
    
    @Previewable @State var selectedEntry : Entry?
    
    @Previewable @State var detailsPresented : Bool = false
    
    @Previewable @State var entryDelete : Bool = false
    
    @Previewable @State var dataStructure : ME_DataStructure<String, Date, Folder, Entry, LoadableResource> = Database.previewDB
    
    List {
        ME_ContentViewEntrySection(
            dataStructure: dataStructure,
            selectedEntry: $selectedEntry,
            entryDetailsPresented: $detailsPresented,
            entryDelete: $entryDelete
        )
    }
}
