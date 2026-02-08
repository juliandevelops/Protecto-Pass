//
//  EditFolder.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddFolder.swift on 28.07.23.
//
//  Renamed by Julian Schumacher to EditFolder.swift on 26.08.23.
//

import SwiftUI

/// A Screen to create a new Folder which then
/// is added to the Database
internal struct EditFolder: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var db : Database
    
    /// The name of the Folder
    @State private var name : String = ""
    
    @State private var description : String = ""
    
    /// The parent folder of this Folder
    @State private var superID : UUID
    
    @State private var storeInFolder : Bool = false
    
    @State private var errStoring : Bool = false
    
    @State private var iconName : String = "folder"
    
    @State private var iconChooserShown : Bool = false
    
    @State private var folder : Folder? = nil
    
    internal init(
        storeIn superID : UUID,
        folder : Folder? = nil
    ) {
        self.superID = superID
        if let f = folder {
            self.folder = f
            name = f.name
            description = f.description
            iconName = f.iconName
        }
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
                        IconChooser(iconName: $iconName, type: .folder)
                    }
                }
                Section("Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...10)
                }
                Section("Storing") {
                    Toggle(isOn: $storeInFolder.animation()) {
                        Label("Store in Folder", systemImage: "folder")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .alert("Error saving", isPresented: $errStoring) {
                Button("Cancel", role: .cancel) {}
                Button("Try again") { save() }
            } message: {
                Text("An Error occurred when trying to save the data.\nPlease try again")
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarBackButtonHidden()
            .toolbarRole(.editor)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Saves the Data and dismisses this View
    private func save() -> Void {
        do {
            try Storage.storeDatabase(
                db,
                context: context,
                newElements: [
                    Folder(
                        name: name,
                        description: description,
                        folders: folder?.folders ?? [],
                        entries: folder?.entries ?? [],
                        images: folder?.images ?? [],
                        videos: folder?.videos ?? [],
                        iconName: iconName,
                        documents: folder?.documents ?? [],
                        created: folder?.created ?? Date.now,
                        lastEdited: Date.now,
                        id: folder?.id ?? UUID()
                    )
                ],
                superID: superID
            )
            dismiss()
        } catch {
            errStoring.toggle()
        }
    }
}

internal struct EditFolder_Previews: PreviewProvider {
    
    @StateObject private static var database : Database = Database.previewDB
    
    static var previews: some View {
        EditFolder(storeIn: database.id)
            .environmentObject(database)
    }
}
