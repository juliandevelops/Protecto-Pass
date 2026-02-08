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
    @StateObject internal var db : Database
    
    /// Whether the Popover on the action button is presented or not
    @State private var addPopoverPresented : Bool = false
    
    var body: some View {
        NavigationStack {
            ME_ContentView(db)
                .environmentObject(db)
        }
    }
}

internal struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(db: Database.previewDB)
    }
}

internal struct Home_LargeScreen_Previews: PreviewProvider {
    static var previews: some View {
        Home(db: Database.previewDB)
            .environment(\.largeScreen, true)
    }
}
