//
//  FileImportHandler.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 15.09.24.
//

import Foundation
import SwiftUI
import CoreData

internal struct FileImportHandler {
    
    internal static func handleDocumentPickerInput(
        result : Result<[URL], any Error>,
        documents : Binding<[DB_Document]>,
        storeIn db : Database,
        context : NSManagedObjectContext,
        onSuperID superID : UUID
    ) throws -> Void {
        switch result {
            case .success(let files):
                var docs : [DB_Document] = []
                for file in files {
                    guard file.startAccessingSecurityScopedResource() else { return }
                    do {
                        let data = try Data(contentsOf: file, options: [.uncached])
                        docs.append(
                            DB_Document(
                                document: data,
                                type: file.pathExtension.lowercased(),
                                name: file.lastPathComponent,
                                created: Date.now,
                                lastEdited: Date.now,
                                id: UUID()
                            )
                        )
                    } catch {
                        throw DocumentLoadingError()
                    }
                    file.stopAccessingSecurityScopedResource()
                }
                documents.wrappedValue.append(contentsOf: docs)
                do {
                    try Storage.storeDatabase(db, context: context, newElements: docs, superID: superID)
                } catch {
                    throw DocumentSavingError()
                }
            case .failure:
                throw DocumentLoadingError()
        }
    }
}
