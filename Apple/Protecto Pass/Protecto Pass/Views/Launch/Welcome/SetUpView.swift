//
//  SetUpView.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI
import CoreData

/// The View shown to the User while Loading Data
/// in the App and setting up everything
internal struct SetUpView: View {
    
    /// The View Context to interact with Core Data System, loading Data if any are there.
    @Environment(\.managedObjectContext) private var viewContext
    
    /// When the App is ready, this is set to true
    @State private var isReady : Bool = false
    
    /// When set to true, toggles an alert displaying an error message
    @State private var errInitPresented : Bool = false
    
    /// All the encrypted Databases after loading them from the different places
    @State private var databases : [EncryptedDatabase] = []
    
    var body: some View {
        build()
    }
    
    @ViewBuilder
    private func build() -> some View {
        if isReady {
            HomeSelector(databases: databases)
        } else {
            VStack {
                ProgressView()
                    .padding(10)
                Text("Loading...")
                Text("This could take a while, depending on your Database size & count")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 0.5)
            }
            .onAppear {
                load()
            }
            .alert("Error", isPresented: $errInitPresented) {
            } message: {
                Text("An Error occurred while loading. \nPlease force close and restart the Application")
            }
        }
    }
    
    private func load() -> Void {
        do {
            // TODO: change array
            databases = try Storage.load(with: viewContext, and: [])
            isReady.toggle()
        } catch {
            errInitPresented.toggle()
        }
    }
}

/// The Preview for this View
internal struct SetUpView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
