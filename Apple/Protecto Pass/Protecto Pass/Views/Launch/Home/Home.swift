//
//  Home.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.05.23.
//

import SwiftUI

/// The Home View, containing the unlocked
/// Database
internal struct Home: View {
    
    /// The Database that the User has just unlocked
    @EnvironmentObject private var navigationSheet : AddDB_Navigation

    /// Whether the Popover on the action button is presented or not
    @State private var addPopoverPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            ME_ContentView(navigationSheet.vaultSession!.database)
                .environmentObject(navigationSheet.vaultSession!)
        }
    }
}

/// Preview of the preview database in the home view
internal struct Home_Previews: PreviewProvider {
    // TODO: add environment object in preview
    static var previews: some View {
        Home()
    }
}

/// Preview of the preview database with the largeScreen Mode active
internal struct Home_LargeScreen_Previews: PreviewProvider {
    // TODO: add environment object in preview
    static var previews: some View {
        Home()
            .environment(\.largeScreen, true)
    }
}
