//
//  DocumentDetails.swift
//  Protecto Pass
//
//  Created by Julian Schumacher on 07.09.24.
//

import SwiftUI
import PDFKit

internal struct DocumentDetails: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding internal var document : DB_Document?
    
    @Binding internal var delete : Bool
    
    @State private var errLoadingFormat : Bool = false
    
    @State private var formattedString : NSAttributedString? = nil
    
    @State private var markdownString : NSAttributedString? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if document!.isText() {
                    ScrollView {
                        if let fString = formattedString {
                            Text(AttributedString(fString))
                        } else {
                            Text(DataConverter.dataToString(document!.document))
                        }
                    }
                    .onAppear {
                        guard document!.isFormattedText() else { return }
                        do {
                            if document!.type == "rtf" {
                                formattedString = try NSAttributedString(
                                    data: document!.document,
                                    options: [.documentType : NSAttributedString.DocumentType.rtf],
                                    documentAttributes: nil
                                )
                            } else if document!.type == "md" {
                                formattedString = try NSAttributedString(
                                    markdown: DataConverter.dataToString(document!.document),
                                    options: .init(
                                        allowsExtendedAttributes: true,
                                        interpretedSyntax: .inlineOnlyPreservingWhitespace,
                                        failurePolicy: .returnPartiallyParsedIfPossible,
                                        appliesSourcePositionAttributes: false
                                    )
                                )
                            }
                        } catch {
                            errLoadingFormat.toggle()
                        }
                    }
                    .padding(.horizontal, 25)
                    .alert("Error loading Format", isPresented: $errLoadingFormat) {
                        Button("Display plain Text") {
                            formattedString = nil
                        }
                    }
                } else if document!.isPDF() {
                    PDFDocumentDetailsView(pdfDocument: document)
                } else {
                    Text("This type of document can't be displayed directly in the App")
                }
            }
            .navigationTitle(document!.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        NavigationLink {
                            DocumentInfo(document: document!)
                        } label: {
                            Label("Information", systemImage: "info.circle")
                        }
                        Divider()
                        Button(role: .destructive) {
                            delete = true
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
    }
}

// https://stackoverflow.com/questions/65658339/how-to-implement-pdf-viewer-to-swiftui-application
// https://stackoverflow.com/a/65659435
private struct PDFDocumentDetailsView: UIViewRepresentable {
    
    fileprivate let pdfDocument : DB_Document?
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView : PDFView = PDFView()
        pdfView.document = PDFDocument(data: pdfDocument!.document)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: pdfDocument!.document)
    }
}


internal struct PDFDocumentDetailsPreview : PreviewProvider {
    
    @State private static var pdfDocument : DB_Document? = DB_Document(
        document: Data(),
        type: "pdf",
        name: "Test Document",
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    @State private static var delete : Bool = false
    
    static var previews: some View {
        DocumentDetails(
            document: $pdfDocument,
            delete: $delete
        )
    }
}

internal struct TextDocumentDetailsPreview : PreviewProvider {
    
    @State private static var document : DB_Document? = DB_Document(
        document: DataConverter.stringToData("Test Data"),
        type: "txt",
        name: "Test Document",
        created: Date.now,
        lastEdited: Date.now,
        id: UUID()
    )
    
    @State private static var delete : Bool = false
    
    static var previews: some View {
        DocumentDetails(document: $document, delete: $delete)
    }
}
