//
//  IconChooser.swift
//  Protecto Pass
//
//  Created by Julian Schumacher as AddDB_IconChooser.swift on 04.09.23.
//
//  Renamed by Julian Schumacher to IconChooser.swift on 04.09.23.
//

import SwiftUI

private enum IconTypes : String, RawRepresentable, Identifiable {
    
    var id : Self { self }
    
    case database
    case folder
    case entry
    case mode
}

internal enum IconChooserCaller {
    case database
    case folder
    case entry
}

/// View to choose the Icon for a Database
internal struct IconChooser: View {
    
    @Environment(\.dismiss) private var dismiss
    
    internal init(
        iconName : Binding<String>,
        type : IconChooserCaller
    ) {
        self._iconName = iconName
        self.type = type
        iconTypes = []
        iconTypes = getIconTypes()
    }
    
    /// Where to store the result
    @Binding private var iconName : String
    
    /// The Type this is called of
    private let type : IconChooserCaller
    
    /// The Name of all the Icons the User can choose from
    private static let iconNames : [IconTypes : [String]] = [
        .database : [
            "externaldrive",
            "externaldrive.fill",
            "tray",
            "tray.fill",
            "tray.full",
            "tray.full.fill",
            "tray.2",
            "tray.2.fill",
            "internaldrive",
            "internaldrive.fill",
            "opticaldiscdrive",
            "opticaldiscdrive.fill",
            "archivebox",
            "archivebox.fill"
        ],
        .folder : [
            "folder",
            "folder.badge.person.crop",
            "folder.fill.badge.person.crop",
            "folder.badge.gearshape",
            "folder.fill.badge.gearshape",
            "books.vertical",
            "books.vertical.fill",
            
        ],
        .entry : [
            "doc",
            "doc.fill",
            "doc.badge.ellipsis",
            "doc.fill.badge.ellipsis",
            "doc.badge.gearshape",
            "doc.badge.gearshape.fill",
            "doc.text",
            "doc.text.fill",
            "doc.zipper",
            "doc.on.doc",
            "doc.on.doc.fill",
            "doc.on.clipboard",
            "doc.on.clipboard.fill",
            "clipboard",
            "clipboard.fill",
            "list.bullet.clipboard",
            "list.bullet.clipboard.fill",
            "list.clipboard",
            "list.clipboard.fill",
            "doc.richtext",
            "doc.richtext.fill",
            "doc.plaintext",
            "doc.plaintext.fill",
            "doc.append",
            "doc.append.fill",
            "doc.text.below.ecg",
            "doc.text.below.ecg.fill",
            "chart.bar.doc.horizontal",
            "chart.bar.doc.horizontal.fill",
            "list.bullet.rectangle.portrait",
            "list.bullet.rectangle.portrait.fill",
            "doc.text.magnifyingglass",
            "list.bullet.rectangle",
            "list.bullet.rectangle.fill",
            "list.dash.header.rectangle",
            "terminal",
            "terminal.fill",
            "note",
            "note.text",
            "calendar",
            "book",
            "book.fill",
            "book.closed",
            "book.closed.fill",
            "character.book.closed",
            "character.book.closed.fill",
            "text.book.closed",
            "text.book.closed.fill",
            "menucard",
            "menucard.fill",
            "greetingcard",
            "greetingcard.fill",
            "magazine",
            "magazine.fill",
            "newspaper",
            "newspaper.fill",
            "doc.text.image",
            "doc.text.image.fill",
            "bookmark",
            "bookmark.fill",
            
        ],
        .mode : [
            "car",
            "car.fill",
            "house",
            "house.fill"
        ]
    ]
    
    private var iconTypes : [IconTypes]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    buildGrid()
                }
            }
            .padding(.top, 15)
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
            .toolbar(.automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildGrid() -> some View {
        ForEach(iconTypes) {
            iconType in
            Section {
                ForEach(IconChooser.iconNames[iconType]!, id: \.self) {
                    iconName in
                    Button {
                        done(iconName)
                    } label: {
                        Image(systemName: iconName)
                            .renderingMode(.original)
                            .symbolRenderingMode(.hierarchical)
                            .resizable()
                            .scaledToFit()
                            .padding(25)
                    }
                    .foregroundColor(.primary)
                }
            } header: {
                HStack {
                    Text(iconType.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.light)
                        .padding(.horizontal, 15)
                    Spacer()
                }
            }
        }
    }
    
    private func getIconTypes() -> [IconTypes] {
        var icons : [IconTypes] = []
        switch type {
        case .database:
            icons.append(.database)
        case .folder:
            icons.append(.folder)
        case .entry:
            icons.append(.entry)
        }
        icons.append(.mode)
        return icons
    }
    
    private func done(_ iconName : String) -> Void {
        self.iconName = iconName
        dismiss()
    }
}

internal struct IconChooser_Database_Previews: PreviewProvider {
    
    @State private static var iconName : String = ""
    
    static var previews: some View {
        IconChooser(iconName: $iconName, type: .database)
    }
}

internal struct IconChooser_Folder_Previews: PreviewProvider {
    
    @State private static var iconName : String = ""
    
    static var previews: some View {
        IconChooser(iconName: $iconName, type: .folder)
    }
}

internal struct IconChooser_Entry_Previews: PreviewProvider {
    
    @State private static var iconName : String = ""
    
    static var previews: some View {
        IconChooser(iconName: $iconName, type: .entry)
    }
}
