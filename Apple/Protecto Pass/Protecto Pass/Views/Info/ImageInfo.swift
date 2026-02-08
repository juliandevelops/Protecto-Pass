//
//  ImageInfo.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 27.08.24.
//

import SwiftUI

internal struct ImageInfo: View {
    
    @Environment(\.dismiss) private var dismiss
    
    internal let image : DB_Image?
    
    var body: some View {
        List {
            Section("General") {
                ListTile(name: "Quality", data: String(image!.quality))
            }
            Section("Timeline") {
                ListTile(name: "Created", date: image!.created)
                ListTile(name: "Last edited", date: image!.lastEdited)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbarRole(.navigationStack)
        .toolbar(.automatic, for: .navigationBar)
    }
}

#Preview {
    ImageInfo(image: DB_Image.previewImage)
}
