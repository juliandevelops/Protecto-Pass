//
//  ListTile.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 31.05.23.
//

import SwiftUI

/// A Default List Tile displaying Name and Data
/// of the Data being displayed
internal struct ListTile: View {

    internal init(
        name : String,
        data: String,
        textContentType : UITextContentType? = nil,
        onTap : @escaping () -> () = {}
    ) {
        self.name = name
        self.data = data
        self.date = nil
        self.dateStyle = nil
        self.onTap = onTap
    }

    internal init(
        name : String,
        date : Date,
        style : Text.DateStyle = .date,
        onTap : @escaping () -> () = {}
    ) {
        self.name = name
        self.data = nil
        self.date = date
        self.dateStyle = style
        self.onTap = onTap
    }
    
    /// The Name of this List Tile's Data
    private let name : String
    
    /// The actual Data of this List Tile
    private let data : String?

    private let date : Date?

    private let dateStyle : Text.DateStyle?
    
    /// The Action that is called when the User taps on the
    /// List Tile
    private var onTap : () -> () = {}
    
#if !os(macOS)
    /// The Text Content Type of the Data Part
    internal var textContentType : UITextContentType? = nil
#endif
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if data != nil {
                Text(data!)
                    .foregroundColor(.gray)
#if !os(macOS)
                    .textContentType(textContentType)
#endif
            } else {
                Text(date!, style: dateStyle!)
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct ListTile_Previews: PreviewProvider {
    static var previews: some View {
        ListTile(
            name: "Test",
            data: "Value",
            onTap: {
                print("On Tap pressed")
            }
        )
    }
}
