//
//  AlbumLibraryView.swift
//  SwanSong
//
//  Created by Daniel Marriner on 14/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SwiftUI
import ASCollectionView
import MediaPlayer

struct AlbumLibraryView: View {
    @State var isInListMode = true
    @Binding var isPresentingPlayer: Bool
    var albums: (collections: [MPMediaItemCollection], sections: [MPMediaQuerySection]) {
        let query = MPMediaQuery.albums()
        return (query.collections ?? [], query.collectionSections ?? [])
    }

    var body: some View {
        List {
            ForEach(albums.sections, id: \.self) { section in
                Section(header: Text(section.title)) {
                    let range = section.range
//                    if isInListMode {
                    ForEach(range.lowerBound..<range.upperBound) { index in
                        let collection = albums.collections[index]
                        NavigationLink(destination: AlbumView(
                            isPresentingPlayer: $isPresentingPlayer,
                            persistentID: collection.representativeItem?.albumPersistentID)) {
                            ArtDetailListCell(
                                title: collection.representativeItem?.albumTitle ?? "No Title",
                                detail: collection.representativeItem?.albumArtist ?? "Unknown artist",
                                image: collection.representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)),
                                size: .medium
                            )
                        }
                    }
//                    } else {
//                        ASCollectionView {
//                            ASCollectionViewSection(
//                                id: section.title,
//                                data: albums.collections[range.lowerBound..<range.upperBound],
//                                dataID: \.self
//                            ) { item, _ in
//                                Text("No title")
//                            }
//                        }
//                        .layout { sectionID in
//                            return .grid(
//                                itemSpacing: 10,
//                                lineSpacing: 10,
//                                itemSize: .absolute(90)
//                            )
//                        }
//                    }
                }
            }
        }
        .listStyle(PlainListStyle())
//        .modifier(VerticalIndex(indexableList: albums.1.map({ $0.title })))
        .navigationBarTitle("Albums")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            leading: Button {
                withAnimation { self.isInListMode.toggle() }
            } label: { Image(systemSymbol: .rectangleGrid2x2) }
            .font(.system(size: 25)),
            trailing: Button {
                withAnimation { self.isPresentingPlayer = true }
            } label: { Image(systemSymbol: .playFill) }
            .font(.system(size: 25))
        )
    }
}

/// Code courtesy of Mozahler
/// https://stackoverflow.com/questions/58809357/swiftui-list-with-section-index-on-right-hand-side
//struct VerticalIndex: ViewModifier {
//    let indexableList: [String]
//    func body(content: Content) -> some View {
//        var body: some View {
//            ScrollViewReader { scrollProxy in
//                ZStack {
//                    content
//                    VStack {
//                        ForEach(indexableList, id: \.self) { letter in
//                            HStack {
//                                Spacer()
//                                Button(action: {
//                                    withAnimation {
//                                        scrollProxy.scrollTo(letter)
//                                    }
//                                }, label: {
//                                    Text(letter)
//                                        .font(.system(size: 12))
//                                        .padding(.trailing, 7)
//                                })
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return body
//    }
//}
