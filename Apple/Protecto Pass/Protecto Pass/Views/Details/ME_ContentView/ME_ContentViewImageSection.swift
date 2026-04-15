//
//  ME_ContentViewImageSection.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 24.09.24.
//

import SwiftUI
import PhotosUI

internal struct ME_ContentViewImageSection: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var db : Database
    
    @ObservedObject private var dataStructure :  DB_ME_DataStructure<
        String,
        Date,
        DB_Folder,
        DB_Entry,
        DB_LoadableResource,
        DB_CreditCard,
        DB_Note,
        DB_Passkey,
        UUID,
        DB_Tag
    >

    private var metrics : GeometryProxy
    
    internal init(
        dataStructure:  DB_ME_DataStructure<
        String,
        Date,
        DB_Folder,
        DB_Entry,
        DB_LoadableResource,
        DB_CreditCard,
        DB_Note,
        DB_Passkey,
        UUID,
        DB_Tag
        >,
        metrics : GeometryProxy,
        errSavingPresented : Binding<Bool>,
        audioVisualItemsToAdd : Binding<[PhotosPickerItem]>,
        addImagePresented : Binding<Bool>
    ) {
        self.dataStructure = dataStructure
        self.metrics = metrics
        self.errSavingPresented = errSavingPresented
        self.audioVisualItemsToAdd = audioVisualItemsToAdd
        self.addImagePresented = addImagePresented
        self.audioVisualObjects = dataStructure.images + dataStructure.videos
    }
    
    /* DATA VARIABLES */
    
    @State private var audioVisualObjects : [DB_LoadableResource]

    /* SELECTED OBJECT VARIABLES */
    
    @State private var selectedImage : DB_LoadableResource?

    @State private var selectedVideo : DB_LoadableResource?
    
    /* SHEET CONTROL VARIABLES */
    
    @State private var detailsPresented : Bool = false
    
    private var addImagePresented : Binding<Bool>
    
    /* DELETION CONFIRMATION DIALOG CONTROL VARIABLES */
    
    @State private var imageDeletionConfirmationShown : Bool = false
    
    @State private var videoDeletionConfirmationShown : Bool = false
    
    /* ERROR ALERT CONTROL VARIABLES */
    
    @State private var errImageDeletionShown : Bool = false
    
    @State private var errVideoDeletionShown : Bool = false
    
    /// Set to true in order to present an alert stating the error while loading an image
    @State private var errLoadingImagePresented : Bool = false
    
    /// Set to true in order to present an alert displaying an error while loading the video
    @State private var errLoadingVideoPresented : Bool = false
    
    private let errSavingPresented : Binding<Bool>
    
    /// The Photos and videos selected to add to the Password Safe
    private var audioVisualItemsToAdd : Binding<[PhotosPickerItem]>
    
    
    var body: some View {
        Section("Images") {
            if !dataStructure.images.isEmpty || !dataStructure.videos.isEmpty {
                if (dataStructure.images.count + dataStructure.videos.count) <= 9 {
                    GroupBox {
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
                            ForEach((dataStructure.images + dataStructure.videos), id: \.id) {
                                lr in
                                Button {
                                    selectedImage = lr
                                    detailsPresented.toggle()
                                } label: {
                                    Image(uiImage: UIImage(data: lr.thumbnailData)!)
                                        .resizable()
                                        .frame(
                                            width: metrics.size.width / 3,
                                            height: metrics.size.width / 3
                                        )
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        selectedImage = lr
                                        imageDeletionConfirmationShown.toggle()
                                    } label: {
                                        Label("Delete Image", systemImage: "trash")
                                    }
                                }
                                .sheet(isPresented: $detailsPresented) {
                                    ImageDetails(
                                        image: selectedImage,
                                        deleted: $imageDeletionConfirmationShown
                                    )
                                }
                                .alert("Delete Image?", isPresented: $imageDeletionConfirmationShown) {
                                    Button("Continue", role: .destructive) {
                                        do {
                                            dataStructure.images.removeAll(where: { $0.id == selectedImage!.id })
//                                            try Storage.deleteImage(id: selectedImage!.id, in: db, with: context)
                                        } catch {
                                            dataStructure.images.append(selectedImage!)
                                            errImageDeletionShown = true
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {
                                        imageDeletionConfirmationShown.toggle()
                                    }
                                } message: {
                                    Text("This Image will be deleted\nThis action is irreversible")
                                }
                                .alert("Delete Video?", isPresented: $videoDeletionConfirmationShown) {
                                    Button("Continue", role: .destructive) {
                                        do {
                                            dataStructure.videos.removeAll(where: { $0.id == selectedImage!.id })
//                                            try Storage.deleteVideo(id: selectedVideo!.id, in: db, with: context)
                                        } catch {
                                            dataStructure.videos.append(selectedVideo!)
                                            errVideoDeletionShown = true
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {
                                        videoDeletionConfirmationShown.toggle()
                                    }
                                } message: {
                                    Text("This Video will be deleted\nThis action is irreversible")
                                }
                                .alert("Error deleting Image", isPresented: $errImageDeletionShown) {
                                } message: {
                                    Text("There's been an error deleting the Image")
                                }
                                .alert("Error deleting Video", isPresented: $errVideoDeletionShown) {
                                } message: {
                                    Text("There's been an error deleting the Video")
                                }
                            }
                        }
                    }
                } else {
                    NavigationLink {
                        ImageListDetails(audioVisualObjects: $dataStructure.images, superID: dataStructure.id)
                            .environmentObject(db)
                    } label: {
                        Label("Show all images (\(dataStructure.images.count))", systemImage: "photo")
                    }
                    .foregroundStyle(.primary)
                }
            } else {
                Text("No Images found")
            }
        }
        .alert("Error loading Image", isPresented: $errLoadingImagePresented) {
        } message: {
            Text("There's been an error while trying to load this image")
        }
        .alert("Error loading Video", isPresented: $errLoadingVideoPresented) {
        } message: {
            Text("There's been an error while trying to load this video")
        }
        .onChange(of: addImagePresented.wrappedValue) {
            Task {
                do {
                    try await PhotoPickerHandler.handlePhotoPickerInput(
                        items: audioVisualItemsToAdd.wrappedValue,
                        pickerPresented: addImagePresented.wrappedValue,
                        loadableResources: $audioVisualObjects,
                        storeIn: db,
                        with: context,
                        onSuperID: dataStructure.id
                    )
                    guard !addImagePresented.wrappedValue else { return }
                    audioVisualItemsToAdd.wrappedValue.removeAll()
                } catch is PhotoPickerImageConverterError {
                    errLoadingImagePresented.toggle()
                } catch is PhotoPickerVideoConverterError {
                    errLoadingVideoPresented.toggle()
                } catch is PhotoPickerResultsSavingError {
                    errSavingPresented.wrappedValue.toggle()
                }
            }
        }
    }
}

#Preview {
    
    @Previewable @State var dataStructure :  DB_ME_DataStructure<
        String,
        Date,
        DB_Folder,
        DB_Entry,
        DB_LoadableResource,
        DB_CreditCard,
        DB_Note,
        DB_Passkey,
        UUID,
        DB_Tag
    > = Database.previewDB

    @Previewable @State var errSavingPresented : Bool = false
    
    @Previewable @State var audioVisualItemsToAdd : [PhotosPickerItem] = []
    
    @Previewable @State var addImagePresented : Bool = false
    
//    List {
//        GeometryReader {
//            metrics in
//            ME_ContentViewImageSection(
//                dataStructure: dataStructure,
//                metrics: metrics,
//                errSavingPresented: $errSavingPresented,
//                audioVisualItemsToAdd: $audioVisualItemsToAdd,
//                addImagePresented: $addImagePresented
//            )
//        }
//    }
}
