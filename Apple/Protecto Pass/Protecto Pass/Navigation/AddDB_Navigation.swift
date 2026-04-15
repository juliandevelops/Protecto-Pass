//
//  AddDB_Navigation.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 21.07.23.
//

import Foundation
import Combine

internal final class AddDB_Navigation : ObservableObject {
    /// Whether the Sheet to add / create a new Database is shown or not
    @Published internal var databaseAddingSheetShown : Bool = false
    
    /// When toggled / set to true, this activates the navigation to the
    /// Home Menu when unlocking the Database
    @Published internal var openDatabaseToHome : Bool = false
    
    /// The current vault session for the unlocked database
    @Published internal var vaultSession : VaultSession?
}
