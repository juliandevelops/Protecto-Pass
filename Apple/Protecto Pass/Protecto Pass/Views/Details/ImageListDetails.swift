//
//  ImageListDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 23.01.24.
//

import SwiftUI
import PhotosUI

internal struct ImageListDetails: View {
    
    @Environment(\.managedObjectContext) private var context
    
    /// The full database needed to store it
    @EnvironmentObject private var db : Database
    
    @Binding internal var audioVisualObjects : [DB_LoadableResource]

    @State private var imageDetailsPresented : Bool = false
    
    @State private var selectedObject : DB_LoadableResource?

    @State private var addImagePresented : Bool = false
    
    @State private var itemsSelected : [PhotosPickerItem] = []
    
    @State private var imageDeleted : Bool = false
    
    internal let superID : UUID
    
    var body: some View {
        NavigationStack {
            // TODO: GeometryReader destorys Layout, find workaround
            GeometryReader {
                metrics in
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .fixed(metrics.size.width / 3),
                                spacing: 2
                            ),
                            GridItem(
                                .fixed(metrics.size.width / 3),
                                spacing: 2
                            ),
                            GridItem(
                                .fixed(metrics.size.width / 3),
                                spacing: 2
                            ),
                        ],
                        spacing: 2
                    ) {
                        ForEach(audioVisualObjects, id: \.id) {
                            lr in
                            Button {
                                selectedObject = lr
                                imageDetailsPresented.toggle()
                            } label: {
                                Image(uiImage: UIImage(data: lr.thumbnailData)!)
                                    .resizable()
                                    .frame(
                                        width: metrics.size.width / 3,
                                        height: metrics.size.width / 3
                                    )
                            }
                        }
                    }
                }
            }
            .photosPicker(
                isPresented: $addImagePresented,
                selection: $itemsSelected,
                maxSelectionCount: 100,
                selectionBehavior: .continuousAndOrdered,
                matching: .any(of: [.images, .videos]),
                preferredItemEncoding: .automatic
            )
            .onChange(of: addImagePresented) {
                Task {
                    do {
                        try await PhotoPickerHandler.handlePhotoPickerInput(
                            items: itemsSelected,
                            pickerPresented: addImagePresented,
                            loadableResources: $audioVisualObjects,
                            storeIn: db,
                            with: context,
                            onSuperID: superID
                        )
                        guard !addImagePresented else { return }
                        itemsSelected.removeAll()
                    }
                }
            }
              // TODO: change to binding(?) and dialog
            .onChange(of: imageDeleted) {
                do {
//                    try Storage.deleteImage(id: selectedObject!.id, in: db, with: context)
                    audioVisualObjects.removeAll(where: { $0.id == selectedObject!.id })
                    selectedObject = nil
                    // TODO: remove loadable resource reference
                } catch {
                    // TODO: handle error
                }
            }
            .sheet(isPresented: $imageDetailsPresented) {
                ImageDetails(image: selectedObject, deleted: $imageDeleted)
            }
            .navigationTitle("Images & Videos")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addImagePresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}


internal struct ImageListDetails_Previews: PreviewProvider {
    
    @State static private var objects : [DB_LoadableResource] = []
    
    @StateObject static private var db : Database = Database.previewDB
    
    static var previews: some View {
        ImageListDetails(audioVisualObjects: $objects, superID: db.id)
            .environmentObject(db)
    }
}
