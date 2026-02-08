//
//  ImageDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 05.09.23.
//

import SwiftUI

/// Struct to display an Image stored in this Database
internal struct ImageDetails: View {
    
    /// Action to dismiss this View
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    /// The Image displayed in this View
    @State internal var image : LoadableResource?
    
    @State internal var loadedImage : DB_Image?
    
    /// Binding to show the deletion confirmation dialog
    @Binding internal var deleted : Bool
    
    /// Displays an alert displaying an error while loading resources
    @State private var errLoadingResourcesShown : Bool = false
    
    private func loadResource() -> Void {
        do {
            loadedImage = try Storage.loadImages(db, ids: [image?.id ?? UUID()], context: context).first
        } catch {
            errLoadingResourcesShown.toggle()
        }
    }
    
    var body: some View {
        NavigationStack {
            builder()
                .toolbarRole(.navigationStack)
                .toolbar(.automatic, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            NavigationLink {
                                ImageInfo(image: loadedImage)
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            Divider()
                            Button(role: .destructive) {
                                deleted = true
                                dismiss()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
        }
        .alert("Error loading resources", isPresented: $errLoadingResourcesShown) {
        } message: {
            Text("There's been an error while trying to load the resource from the file system")
        }
        .onAppear {
            loadResource()
        }
    }
    
    @ViewBuilder
    private func builder() -> some View {
        if let img = loadedImage {
            Image(uiImage: img.image)
                .resizable()
                .scaledToFit()
        } else {
            Text("image Loading...")
        }
    }
}

internal struct ImageDetails_Previews: PreviewProvider {
    
    @State static private var image : LoadableResource = LoadableResource(id: UUID(), thumbnailData: Data())
    
    @State static private var deleted : Bool = false
    
    static var previews: some View {
        ImageDetails(image: image, deleted: $deleted)
    }
}
