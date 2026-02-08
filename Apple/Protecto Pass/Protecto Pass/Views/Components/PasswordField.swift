//
//  PasswordField.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 03.09.23.
//

import SwiftUI

/// Password Field to enter a Password Securely
internal struct PasswordField: View {
    
    /// The Title of this Password Field
    internal let title : String
    
    /// Where to write the text to
    @Binding internal var text : String

    /// Whether this is a new Password or not
    internal var newPassword : Bool = false
    
    /// Whether the Password is shown or not
    @State private var isShown : Bool = false
    
    var body: some View {
        field()
            .textContentType(newPassword ? .newPassword : .password)
            .autocorrectionDisabled()
            .textCase(.none)
            .textInputAutocapitalization(.never)
            .keyboardType(.asciiCapable)
        // TODO: change, because text is deleted when changing
//            .onChange(of: text) {
//                _ in
//                if isShown {
//                    isShown.toggle()
//                }
//            }
    }
    
    @ViewBuilder
    private func field() -> some View {
        ZStack {
            if isShown {
                TextField(title, text: $text)
            } else {
                SecureField(title, text: $text)
            }
            HStack {
                Spacer()
                Button {
                    withAnimation(.easeOut) {
                        isShown.toggle()
                    }
                } label: {
                    Image(systemName: isShown ? "eye.slash" : "eye")
                }
                .foregroundStyle(.foreground)
                .padding(.trailing, 10)
            }
        }
    }
}

internal struct PasswordField_Previews: PreviewProvider {
    
    @State private static var password : String = ""
    
    static var previews: some View {
        PasswordField(title: "Password", text: $password)
    }
}
