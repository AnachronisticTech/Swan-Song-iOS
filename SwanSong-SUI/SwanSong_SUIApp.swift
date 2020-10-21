//
//  SwanSong_SUIApp.swift
//  SwanSong-SUI
//
//  Created by Daniel Marriner on 18/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SwiftUI
import MediaPlayer

var Formatter: DateComponentsFormatter {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter
}

let filterLocal = MPMediaPropertyPredicate(
    value: false,
    forProperty: MPMediaItemPropertyIsCloudItem
)

@main
struct SwanSong_SUIApp: App {
    let persistenceController = PersistenceController.shared
    let player = AudioPlayer()
    let preferences = Preferences()

    @State var selectedTab = 0
    @State var isPresentingPlayer = false

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationView {
                    AlbumLibraryView(isPresentingPlayer: $isPresentingPlayer)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .tabItem {
                    Image(uiImage: UIImage(named: selectedTab == 0 ? "albums_fill" : "albums")!)
                    Text("Albums")
                }
                .tag(0)

                NavigationView {
                    VibranceTestView()
                }
                .tabItem {
                    Image(systemSymbol: .musicMic)
                    Text("Artists")
                }
                .tag(1)

                NavigationView {
                    UserInterface()
                }
                .tabItem {
                    Image(systemSymbol: .musicNoteList)
                    Text("Playlists")
                }
                .tag(2)

                NavigationView {
                    Text("Songs")
                }
                .tabItem {
                    Image(systemSymbol: .musicNote)
                    Text("Songs")
                }
                .tag(3)

                NavigationView {
                    Text("Settings")
                }
                .tabItem {
                    Image(systemSymbol: .gear)
                    Text("Settings")
                }
                .tag(4)

                NavigationView {
                    Text("Genres")
                }
                .tabItem {
                    Image(uiImage: UIImage(named: "genres")!)
                    Text("Genres")
                }
                .tag(5)
            }
            .sheet(isPresented: $isPresentingPlayer) {
                PlayerView(isPresented: $isPresentingPlayer)
                    .environmentObject(player)
                    .environmentObject(preferences)
            }
        }
    }
}
