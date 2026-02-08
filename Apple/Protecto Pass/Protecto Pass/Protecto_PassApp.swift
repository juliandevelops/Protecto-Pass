//
//  Protecto_PassApp.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 01.04.23.
//

import SwiftUI
import CoreData

@main
internal struct Protecto_PassApp: App {

    /// The Phase the app is in currently
    @Environment(\.scenePhase) private var scenePhase

    /// The Persistence Controller used in this App to store Data
    private let persistenceController : PersistenceController = PersistenceController.shared

    /// Indicates whether the "Large Screen" Setting is true or false
    @State private var largeScreen : Bool = false

    /// Whether the compact Mode is activated or not
    @State private var compactMode : Bool = false

    /// Should be toggled to display an alert stating there's been an error
    /// while loading the settings and app data
    @State private var errLoadingSettingsShown : Bool = false

    internal init() {
        var settings : [Settings : Bool] = [:]
        do {
            settings = try SettingsHelper.load(context: persistenceController.container.viewContext)
        } catch {
            errLoadingSettingsShown.toggle()
        }
        compactMode = settings[.compactMode]!
        largeScreen = settings[.largeScreen]!
    }

    var body: some Scene {
        WindowGroup {
            SetUpView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.largeScreen, largeScreen)
                .environment(\.compactMode, compactMode)
                .alert("Error loading Settings", isPresented: $errLoadingSettingsShown) {
                    // No Actions available
                } message: {
                    Text("There's been an Error loading Settings and App Data.")
                }
                .onAppear {
                    do {
                        try SettingsHelper.loadiCloud(with: persistenceController.container.viewContext)
                    } catch {
                        errLoadingSettingsShown.toggle()
                    }
                }
                .onChange(of: scenePhase) {
                    Task {
                        do {
                            // TODO: test and debug
                            let settings : [Settings : Bool] = try SettingsHelper.load(context: persistenceController.container.viewContext)
                            largeScreen = settings[.largeScreen]!
                            compactMode = settings[.compactMode]!
                        } catch {
                            errLoadingSettingsShown.toggle()
                        }
                    }
                }
        }
    }
}
