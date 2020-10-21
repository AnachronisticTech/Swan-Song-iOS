//
//  AlbumView.swift
//  SwanSong-SUI
//
//  Created by Daniel Marriner on 19/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct AlbumView: View {
    @State var showingDetail = false
    @State var persistentID: MPMediaEntityPersistentID? = nil
    var album: (representativeItem: MPMediaItem?, tracks: [MPMediaItem]) {
        let query = MPMediaQuery.albums()
        let filterAlbumID = MPMediaPropertyPredicate(
            value: persistentID,
            forProperty: MPMediaItemPropertyAlbumPersistentID
        )
        query.addFilterPredicate(filterAlbumID)
        query.addFilterPredicate(filterLocal)
        return (query.collections?.first?.representativeItem, query.items ?? [])
    }

    var body: some View {
        List {
            if let item = album.representativeItem {
                ArtDetailListCell(
                    title: item.albumTitle ?? "No title",
                    detail: item.albumArtist ?? "Unknown artist",
                    image: item.artwork?.image(at: CGSize(width: 80, height: 80))
                )
            }
            ForEach(album.tracks, id: \.self) { track in
                NumberDetailListCell(
                    title: track.title ?? "No Title",
                    detail: Formatter.string(from: track.playbackDuration)!,
                    number: track.albumTrackNumber
                )
            }
            FooterListCell(
                detail: "\(album.tracks.count) track\(album.tracks.count == 1 ? "" : "s") - \(Int((album.tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            )
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(album.representativeItem?.albumTitle ?? "No Title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: {
                withAnimation { self.showingDetail.toggle() }
            }) { Image(systemSymbol: .playFill) }
        )
        .sheet(isPresented: $showingDetail) {
            PlayerView(showPlayer: $showingDetail)
        }
    }
}
