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
                ListTile(name: "Created", date: image!.createdDate)
                ListTile(name: "Last edited", date: image!.lastEditedDate)
                ListTile(name: "Last accessed", date: image!.lastAccessedDate)
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
