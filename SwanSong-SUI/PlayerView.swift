//
//  PlayerView.swift
//  SwanSong
//
//  Created by Daniel Marriner on 13/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SwiftUI
import VisualEffects
import SFSafeSymbols

struct PlayerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var player: AudioPlayer
    @EnvironmentObject var preferences: Preferences
    @Binding var isPresented: Bool
    @State var isCloseButtonVisible: Bool = false

    var body: some View {
        ZStack {
            switch player.state {
                case .Playing(let item), .Paused(let item):
                    Image(artwork: item.artwork?.image(at: CGSize(width: 1000, height: 1000)))
                        .backingArtwork()
                case .NotPlaying:
                    Image(artwork: nil)
                        .backingArtwork()
            }
            VisualEffectBlur(
                blurStyle: colorScheme == .dark ? .prominent : .systemThinMaterialDark,
                vibrancyStyle: .fill
            ) {
                Rectangle()
                    .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
            VStack {
                if isCloseButtonVisible {
                    HStack {
                        Spacer()
                        Button {
                            self.isPresented = false
                        } label: {
                            Image(systemSymbol: .xCircleFill)
                                .frame(width: 30, height: 30)
                                .font(.system(size: 30))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .padding(.top)
                    }
                }
                switch player.state {
                    case .Playing(let item), .Paused(let item):
                        Image(artwork: item.artwork?.image(at: CGSize(width: 1000, height: 1000)))
                            .artwork()
                    case .NotPlaying:
                        Image(artwork: nil)
                            .artwork()
                }
                Spacer()
                HStack {
                    Text(Formatter.string(from: player.elapsedTime)!)
                        .font(.system(size: 12))
                        .frame(minWidth: 35)
                    AudioSlider(value: $player.elapsedProportion)
                    Text(Formatter.string(from: player.remainingTime)!)
                        .font(.system(size: 12))
                        .frame(minWidth: 35)
                }
                Spacer()
                switch player.state {
                    case .Playing(let item), .Paused(let item):
                        Text(item.title ?? "No Title")
                            .lineLimit(1)
                            .font(.system(size: 20, weight: .bold))
                        Text(item.artist ?? "Unknown artist")
                            .lineLimit(1)
                            .font(.system(size: 15))
                    case .NotPlaying:
                        Text("Not Playing")
                            .font(.system(size: 20, weight: .bold))
                        Text("")
                            .font(.system(size: 15))
                }
                Spacer()
                VStack {
                    HStack {
                        Button {
                            player.repeatState.toggle()
                        } label: {
                            if player.isRepeating {
                                Image(systemSymbol: .repeat)
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25))
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .background(Color(colorScheme == .dark ? preferences.darkTint.color : preferences.lightTint.color))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(5)
                            } else {
                                Image(systemSymbol: .repeat)
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(5)
                            }
                        }
                        Spacer()
                        Button {
                            player.previous()
                        } label: {
                            Image(systemSymbol: .backwardFill)
                                .frame(width: 50, height: 50)
                                .font(.system(size: 25))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                        Button {
                            if case .Playing = player.state {
                                player.pause()
                            } else if case .Paused = player.state {
                                player.resume()
                            }
                        } label: {
                            if case .Playing = player.state {
                                Image(systemSymbol: .pauseFill)
                                    .frame(width: 50, height: 50)
                                    .font(.system(size: 45))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            } else {
                                Image(systemSymbol: .playFill)
                                    .frame(width: 50, height: 50)
                                    .font(.system(size: 45))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                        Spacer()
                        Button {
                            player.skip()
                        } label: {
                            Image(systemSymbol: .forwardFill)
                                .frame(width: 50, height: 50)
                                .font(.system(size: 25))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                        Button {
                            player.shuffleState.toggle()
                        } label: {
                            if player.isShuffling {
                                Image(systemSymbol: .shuffle)
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25))
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .background(Color(colorScheme == .dark ? preferences.darkTint.color : preferences.lightTint.color))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(5)
                            } else {
                                Image(systemSymbol: .shuffle)
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(5)
                            }
                        }
                    }
                    .padding(.bottom)
                    VolumeView()
                        .frame(height: 30)
                }
                .padding()
            }
            .padding([.leading, .bottom, .trailing])
        }
    }
}

extension Image {
    init(artwork: UIImage?) {
        self.init(uiImage: artwork ?? UIImage(named: "blank_artwork")!)
    }
}

fileprivate extension Image {
    func backingArtwork() -> some View {
        self
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: UIScreen.main.bounds.size.width)
            .clipped()
            .edgesIgnoringSafeArea(.all)
    }

    func artwork() -> some View {
        self
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top)
    }
}
