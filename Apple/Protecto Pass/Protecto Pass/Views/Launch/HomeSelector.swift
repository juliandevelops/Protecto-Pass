//
//  HomeSelector.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.07.23.
//

import SwiftUI

/// View to select between Welcome and Home,
/// depending on the State of the App and whether a
/// Database is unlocked or not
internal struct HomeSelector: View {
    
    internal let databases : [EncryptedDatabase]
    
    /// The Object to control the navigation of and with the AddDB Sheet
    @StateObject private var navigationSheet : AddDB_Navigation = AddDB_Navigation()
    
    var body: some View {
        if navigationSheet.openDatabaseToHome {
            withAnimation {
                Home(db: navigationSheet.db!)
                    .environmentObject(navigationSheet)
            }
        } else {
            Welcome(databases: databases)
                .environmentObject(navigationSheet)
        }
    }
}

/// Preview for the Home Selector
internal struct HomeSelector_Previews: PreviewProvider {
    static var previews: some View {
        HomeSelector(databases: [EncryptedDatabase.previewDB])
    }
}
