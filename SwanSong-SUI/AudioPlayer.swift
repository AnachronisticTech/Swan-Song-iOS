//
//  AudioPlayer.swift
//  SwanSong-SUI
//
//  Created by Daniel Marriner on 20/10/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation
import MediaPlayer
import Combine

class AudioPlayer: ObservableObject {
    enum State {
        case Playing(_ item: MPMediaItem)
        case Paused(_ item: MPMediaItem)
        case NotPlaying

        enum Case { case Playing, Paused, NotPlaying }

        var `case`: Case {
            switch self {
                case .Playing: return .Playing
                case .Paused: return .Paused
                case .NotPlaying: return .NotPlaying
            }
        }
    }

    @Published public private(set) var state = State.NotPlaying
    private var APstate = State.NotPlaying {
        didSet { stateDidChange() }
    }

    private var player = MPMusicPlayerApplicationController.systemMusicPlayer

    var currentTime: TimeInterval {
        get { return player.currentPlaybackTime }
        set { player.currentPlaybackTime = newValue }
    }

    private var timer = Timer()
    @Published public var elapsedTime: TimeInterval = 0
    @Published public var remainingTime: TimeInterval = 0
    @Published public var elapsedProportion: Double = 0

    @Published public private(set) var isShuffling = false
    var shuffleState: Bool {
        get {
            switch player.shuffleMode {
                case .off:
                    return false
                case .songs:
                    return true
                case .default, .albums:
                    fallthrough
                @unknown default:
                    player.shuffleMode = .songs
                    return true
            }
        }
        set {
            player.shuffleMode = newValue ? .songs : .off
            shuffleStateDidChange()
        }
    }

    @Published public private(set) var isRepeating = false
    var repeatState: Bool {
        get {
            switch player.repeatMode {
                case .none:
                    return false
                case .all:
                    return true
                case .default, .one:
                    fallthrough
                @unknown default:
                    player.repeatMode = .all
                    return true
            }
        }
        set {
            player.repeatMode = newValue ? .all : .none
            repeatStateDidChange()
        }
    }

    init() {
        /// If a track is playing already, update `state` to reflect this
        if let track = player.nowPlayingItem {
            switch player.playbackState {
                case .playing:
                    APstate = .Playing(track)
                case .paused:
                    APstate = .Paused(track)
                default: break
            }
        }

        /// Sync @Published var states
        stateDidChange()
        shuffleStateDidChange()
        repeatStateDidChange()

        /// Register to listen for changes in `player.nowPlayingItem`
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingStateDidChange),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil
        )

        /// Register to listen for changes in `player.playbackState`
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackStateDidChange),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil
        )

        /// Set up view update timer
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(setTime),
            userInfo: nil,
            repeats: true
        )
    }

    deinit {
        /// Remove listeners
        NotificationCenter.default.removeObserver(self)
        timer.invalidate()
    }

    @objc func setTime() {
        switch state {
            case .Playing(let item), .Paused(let item):
                elapsedTime = currentTime
                remainingTime = item.playbackDuration - currentTime
                elapsedProportion = currentTime / item.playbackDuration
            case .NotPlaying:
                elapsedTime = 0
                remainingTime = 0
                elapsedProportion = 0
        }
    }

    func play(_ queue: [MPMediaItem], skipping skip: Int = 0) {
        guard skip < queue.count, skip >= 0 else { return }
        let item = queue[skip]
        switch APstate {
            case .NotPlaying:
                player.setQueue(with: MPMediaItemCollection(items: queue))
                player.nowPlayingItem = queue[skip]
            case .Paused(let current), .Playing(let current):
                if current != item {
                    player.setQueue(with: MPMediaItemCollection(items: queue))
                    player.nowPlayingItem = queue[skip]
                }
        }
        let shouldShuffle = shuffleState
        let shouldRepeat = repeatState
        player.play()
        APstate = .Playing(item)
        shuffleState = shouldShuffle
        repeatState = shouldRepeat
    }

    func pause() {
        if case .Playing(let item) = APstate {
            APstate = .Paused(item)
            player.pause()
        }
    }

    func resume() {
        if case .Paused(let item) = APstate {
            APstate = .Playing(item)
            player.play()
        }
    }

    func stop() {
        APstate = .NotPlaying
        player.stop()
    }

    func skip() {
        if case .NotPlaying = APstate { return }
        player.skipToNextItem()
        if let track = player.nowPlayingItem {
            switch APstate {
                case .Playing: APstate = .Playing(track)
                case .Paused : APstate = .Paused(track)
                default: APstate = .NotPlaying
            }
        }
        if case .Paused = APstate {
            player.currentPlaybackTime = 0
        }
    }

    func previous() {
        if case .NotPlaying = APstate { return }
        if let track = player.nowPlayingItem {
            let trackIndex = player.indexOfNowPlayingItem
            let toPrevious = player.currentPlaybackTime < 2 && trackIndex != 0
            switch (APstate, toPrevious) {
                case (.Playing, true):
                    player.skipToPreviousItem()
                    player.currentPlaybackTime = 0
                    APstate = .Playing(track)
                case (.Playing, false):
                    player.skipToBeginning()
                case (.Paused, true):
                    player.skipToPreviousItem()
                    player.currentPlaybackTime = 0
                    APstate = .Paused(track)
                case (.Paused, false):
                    player.skipToBeginning()
                case (.NotPlaying, _): return
            }
        }
    }

    @objc private func nowPlayingStateDidChange() {
        if let item = player.nowPlayingItem {
            if case .playing = player.playbackState {
                APstate = .Playing(item)
            } else if case .paused = player.playbackState {
                APstate = .Paused(item)
            } else if case .stopped = player.playbackState {
                APstate = .NotPlaying
            }
        }
    }

    @objc private func playbackStateDidChange() {
        if case .stopped = player.playbackState {
            APstate = .NotPlaying
        } else if case .paused = player.playbackState, APstate.case != .Paused {
            guard let item = player.nowPlayingItem else {
                APstate = .NotPlaying
                return
            }
            APstate = .Paused(item)
        } else if case .playing = player.playbackState, APstate.case != .Playing {
            guard let item = player.nowPlayingItem else {
                APstate = .NotPlaying
                return
            }
            APstate = .Playing(item)
        }
    }

    func stateDidChange() {
        state = APstate
    }

    func shuffleStateDidChange() {
        isShuffling = shuffleState
    }

    func repeatStateDidChange() {
        isRepeating = repeatState
    }
}
