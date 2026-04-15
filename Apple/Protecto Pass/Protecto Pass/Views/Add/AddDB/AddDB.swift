//
//  AddDB.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 19.04.23.
//

import SwiftUI

/// Provides a Screen with which the User can add and configure their new Database
internal struct AddDB: View {
    
    /// Dismiss Action to dismiss this View
    @Environment(\.dismiss) private var dismiss
    
    /// The Wrapper to this process
    @StateObject private var creationWrapper : DB_CreationWrapper = DB_CreationWrapper()
    
    /// The Databases Name
    @State private var name : String = ""
    
    /// More details about the database
    @State private var details : String = ""

    /// When set to true, navigate to the next screen
    @State private var next : Bool = false
    
    /// When set to true presents and alert that a name is required
    @State private var errEmptyName : Bool = false
    
    /// The Name of the icon, to represent the database
    @State private var iconName : String = "externaldrive"
    
    /// When set to true, the icon chooser view is shown
    @State private var iconChooserShown : Bool = false
    
    var body: some View {
        NavigationStack {
            Button {
                iconChooserShown.toggle()
            } label: {
                Image(systemName: iconName)
                    .renderingMode(.original)
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.foreground)
            }
            .sheet(isPresented: $iconChooserShown) {
                IconChooser(iconName: $iconName, type: .database)
            }
            .padding(.horizontal, 100)
            VStack {
                TextField("Name", text: $name)
                    .padding(.top, 50)
                    .textInputAutocapitalization(.words)
                    .keyboardType(.namePhonePad)
                    .alert("Empty Name", isPresented: $errEmptyName) {
                    } message: {
                        Text("A Name for the Database is required.\nPlease enter one")
                    }
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(3...5)
                        .keyboardType(.asciiCapable)

            }
            .textInputAutocapitalization(.sentences)
            .textCase(.none)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 25)
            .navigationTitle("Add Database")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        abort()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        done()
                    }
                }
            }
            .navigationDestination(isPresented: $next) {
                AddDB_Password()
                    .environmentObject(creationWrapper)
            }
        }
    }

    /// function to complete this part of the database creation.
    /// Call this to navigate to the next screen.
    /// Before navigation, the parameters are stored into the creation wrapper variables to contain
    /// them until actual finisihing the creation of the database.
    private func done() -> Void {
        guard !name.isEmpty else {
            errEmptyName.toggle()
            return
        }
        creationWrapper.name = name
        creationWrapper.details = details
        creationWrapper.iconName = iconName
        next.toggle()
    }

    /// Call this function to abort the creation process.
    /// All data are removed from the creation wrapper
    /// and the sheet is closed.
    private func abort() -> Void {
        creationWrapper.clear()
        dismiss()
    }
}

internal struct AddDB_Previews: PreviewProvider {
    static var previews: some View {
        AddDB()
    }
}
