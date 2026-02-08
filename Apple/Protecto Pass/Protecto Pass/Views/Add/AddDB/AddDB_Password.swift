//
//  AddDB_Password.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 30.05.23.
//

import SwiftUI

/// View in the Database creation process to enter a password
internal struct AddDB_Password: View {
    
    /// The creation wrapper created to begin of this process
    @EnvironmentObject private var creationWrapper : DB_CreationWrapper
    
    /// Whether the passwords are equal or not
    @State private var passwordStatus : Bool = false
    
    /// The Password chosen to create the Database
    @State private var password : String = ""
    
    /// Set to true if the password contains 8 or more character
    @State private var isLengthMet : Bool = false
    
    /// Set to true if the password contains at least one upper case letter
    @State private var containsUpperCaseLetter : Bool = false
    
    /// Set to true if the password contains at least one lower case letter
    @State private var containsLowerCaseLetter : Bool = false
    
    /// Set to true if the password contains at least one number
    @State private var containsNumber : Bool = false
    
    /// Set to true if the password contains at least one symbol
    @State private var containsSymbol : Bool = false
    
    /// When toggled, an alert is displayed telling the user something
    /// went wrong
    @State private var errChecking : Bool = false
    
    /// Set to true if everything checks out and the
    /// creation process is ready for the next step.
    @State private var next : Bool = false
    
    /// When set to true, presents an alert, stating that not all requirements are met.
    @State private var errRequirements : Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "lock.open")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 100)
            PasswordField(title: "Enter a Password", text: $password)
                .autocorrectionDisabled()
                .textContentType(.newPassword)
                .padding(.top, 50)
                .onChange(of: password) {
                    checkRequirements()
                }
                .padding(.top, 10)
                .textCase(.none)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 25)
                .textFieldStyle(.roundedBorder)
                .alert("Missing requirements", isPresented: $errRequirements) {
                    Button("Ok") {}
                } message: {
                    Text("Not all requirements are met.\nPlease meet all the requirements and then try again")
                }
            HStack {
                VStack(alignment: .leading) {
                    Text("Password requirements:")
                    Text("At least:")
                    requirementRow("8 Characters", isMet: isLengthMet)
                    requirementRow("1 Upper Case Letter", isMet: containsUpperCaseLetter)
                    requirementRow("1 Lower Case Letter", isMet: containsLowerCaseLetter)
                    requirementRow("1 number", isMet: containsNumber)
                    requirementRow("1 symbol", isMet: containsSymbol)
                }
                .alert("Error", isPresented: $errChecking) {
                    Button("Ok") {}
                } message: {
                    Text("An Error appear, please try again")
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 25)
                Spacer()
            }
        }
        .navigationDestination(isPresented: $next) {
            AddDB_PasswordVerification()
                .environmentObject(creationWrapper)
        }
        .navigationTitle("Password")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    done()
                }
            }
        }
    }
    
    /// Function executed when the Done Button is pressed
    private func done() -> Void {
        guard allChecked else {
            errRequirements.toggle()
            return
        }
        creationWrapper.password = password
        next.toggle()
    }
    
    /// Whether all requirements are met or not
    private var allChecked : Bool {
        containsUpperCaseLetter && containsLowerCaseLetter && containsNumber && containsSymbol && password.count >= 8
    }
    
    @ViewBuilder
    private func requirementRow(_ requirement : String, isMet : Bool) -> some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle" : "x.circle")
            // Needed for correct color rendering
                .renderingMode(.template)
            // Makes the symbols appear less bold
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isMet ? .green : .red)
            Text(requirement)
        }
    }
    
    /// Checks for the requirements and sets the boolean values
    /// depending on their state
    private func checkRequirements() -> Void {
        // TODO: maybe change regex
        // Length
        isLengthMet = password.count >= 8
        do {
            // Upper Case
            containsUpperCaseLetter = password.contains(try Regex("[A-Z]"))
            // Lower Case
            containsLowerCaseLetter = password.contains(try Regex("[a-z]"))
            // Number
            containsNumber = password.contains(try Regex("[0-9]"))
            // Symbols
            containsSymbol = password.contains(try Regex("[^A-Za-z0-9\\w\\s]"))
        } catch {
            errChecking.toggle()
        }
    }
}

/// View to verify the previously entered password
internal struct AddDB_PasswordVerification : View {
    
    /// The Creation Wrapper for this process
    @EnvironmentObject private var creationWrapper : DB_CreationWrapper
    
    /// The verification password
    @State private var verifyPassword : String = ""
    
    /// When set to true, presents an alert stating that the passwords are different
    @State private var errDifferent : Bool = false
    
    /// Set to true when the passwords are equal and the user can
    /// enter the next screen
    @State private var next : Bool = false
    
    /// Set to true if both passwords are equal
    @State private var equal : Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "lock")
                .renderingMode(.original)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 100)
            PasswordField(title: "Verify Password", text: $verifyPassword, newPassword: true)
                .autocorrectionDisabled()
                .padding(.top, 50)
                .onChange(of: verifyPassword) {
                    checkEqual()
                }
                .padding(.top, 10)
                .textCase(.none)
                .textContentType(.newPassword)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 25)
                .textFieldStyle(.roundedBorder)
                .alert("Different Passwords", isPresented: $errDifferent) {
                    Button("Ok") {}
                } message: {
                    Text("The Passwords are not equal.\nPlease try again.")
                }
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: equal ? "checkmark.circle" : "x.circle")
                            .renderingMode(.template)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(equal ? .green : .red)
                        Text(equal ? "The Passwords are equal" : "The Passwords are not equal")
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                Spacer()
            }
        }
        .navigationDestination(isPresented: $next) {
            AddDB_Overview()
                .environmentObject(creationWrapper)
        }
        .navigationTitle("Verify Password")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    done()
                }
            }
        }
    }
    
    /// Function executed when the next button is pressed
    private func done() -> Void {
        guard equal else {
            errDifferent.toggle()
            return
        }
        next.toggle()
    }
    
    /// Function to check if both Passwords are equal
    private func checkEqual() -> Void {
        if creationWrapper.password == verifyPassword {
            equal = true
        } else {
            equal = false
        }
    }
}

/// The Preview for the initial Password creation Screen
internal struct AddDB_Password_Previews: PreviewProvider {
    
    /// The Wrapper for this preview
    @StateObject private static var creationWrapperPreview : DB_CreationWrapper = DB_CreationWrapper()
    
    static var previews: some View {
        AddDB_Password()
            .environmentObject(creationWrapperPreview)
    }
}

/// The Preview for the Password Verification Screen
internal struct AddDB_PasswordVerification_Previews: PreviewProvider {
    
    /// The Wrapper for this preview
    @StateObject private static var creationWrapperPreview : DB_CreationWrapper = DB_CreationWrapper()
    
    static var previews: some View {
        AddDB_PasswordVerification()
            .environmentObject(creationWrapperPreview)
    }
}
