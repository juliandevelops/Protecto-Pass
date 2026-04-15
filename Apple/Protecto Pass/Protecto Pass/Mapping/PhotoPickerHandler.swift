//
//  PhotoPickerHandler.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 26.08.24.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreData

internal struct PhotoPickerHandler {
    
    internal static nonisolated func handlePhotoPickerInput(
        items : [PhotosPickerItem],
        pickerPresented : Bool,
        loadableResources : Binding<[DB_LoadableResource]>,
        storeIn db : Database,
        with context : NSManagedObjectContext,
        onSuperID superID : UUID
    ) async throws -> Void {
        // Guard to not call this code when opening the Picker
        guard !pickerPresented else { return }
        var selectedDB_Videos : [DB_Video] = []
        var selectedDB_Images : [DB_Image] = []
        var selectedLoadableResources : [DB_LoadableResource] = []
        for item in items {
            if item.supportedContentTypes.contains(where: { $0.isSubtype(of: .audiovisualContent ) }) {
                do {
                    let video = try await item.loadTransferable(type: DBSoleVideo.self)!.videoData
                    selectedDB_Videos.append(
                        DB_Video(
                            videoData: video,
                            createdDate: Date.now,
                            lastEditedDate: Date.now,
                            lastAccessedDate: Date.now,
                            id: UUID(),
                            tags: []
                        )
                    )
                } catch {
                    throw PhotoPickerVideoConverterError()
                }
            } else if item.supportedContentTypes.contains(where: { $0.isSubtype(of: .image) }) {
                do {
                    let image : UIImage = try await item.loadTransferable(type: DBSoleImage.self)!.image
                    selectedDB_Images.append(
                        DB_Image(
                            name: item.itemIdentifier!,
                            image: image,
                            quality: 0.5,
                            createdDate: Date.now,
                            lastEditedDate: Date.now,
                            lastAccessedDate: Date.now,
                            id: UUID(),
                            tags: []
                        )
                    )
                } catch {
                    throw PhotoPickerImageConverterError()
                }
            } else {
                
            }
        }
        do {
//            var newElements : [DatabaseContent<Date, UUID, DB_Tag>] = []
//            newElements.append(contentsOf: selectedDB_Images)
//            newElements.append(contentsOf: selectedDB_Videos)
//            try Storage.storeDatabase(
//                db,
//                context: context,
//                newElements: newElements,
//                superID: superID
//            )
        } catch {
            throw PhotoPickerResultsSavingError()
        }
    }
}

/// The Struct representing the loaded image in this View
private struct DBSoleImage : Transferable {
    
    /// The Image when loading has completed
    fileprivate let image : UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) {
            data in
            guard let image = UIImage(data: data) else {
                throw ImageLoadingError()
            }
            return DBSoleImage(image: image)
        }
    }
}

/// The Struct representing the loaded image in this View
private struct DBSoleVideo : Transferable {
    
    /// The Image when loading has completed
    fileprivate let videoData : Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .movie) {
            data in
            return DBSoleVideo(videoData: data)
        }
    }
}
