//
//  State.swift
//  SwanSong
//
//  Created by Daniel Marriner on 16/06/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioPlayer {
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
    
    public private(set) var state = State.NotPlaying {
        didSet { stateDidChange() }
    }
    
    private var observations = [ObjectIdentifier : Observation]()
    
    private var player = MPMusicPlayerApplicationController.systemMusicPlayer
    
    var currentTime: TimeInterval {
        get { return player.currentPlaybackTime }
        set { player.currentPlaybackTime = newValue }
    }
    
    var isShuffling: Bool {
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
    
    var isRepeating: Bool {
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
                state = .Playing(track)
            case .paused:
                state = .Paused(track)
            default: break
            }
        }
        
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
    }
    
    deinit {
        /// Remove listeners
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, deprecated)
    func refreshState() {
        if let track = player.nowPlayingItem {
            switch player.playbackState {
            case .playing:
                state = .Playing(track)
            case .paused:
                state = .Paused(track)
            default: break
            }
        }
    }
    
    func play(_ queue: [MPMediaItem], skipping skip: Int = 0) {
        guard skip < queue.count, skip >= 0 else { return }
        let item = queue[skip]
        switch state {
        case .NotPlaying:
            player.setQueue(with: MPMediaItemCollection(items: queue))
            player.nowPlayingItem = queue[skip]
        case .Paused(let current), .Playing(let current):
            if current != item {
                player.setQueue(with: MPMediaItemCollection(items: queue))
                player.nowPlayingItem = queue[skip]
            }
        }
        let shouldShuffle = isShuffling
        let shouldRepeat = isRepeating
        player.play()
        state = .Playing(item)
        isShuffling = shouldShuffle
        isRepeating = shouldRepeat
    }
    
    func pause() {
        if case .Playing(let item) = state {
            state = .Paused(item)
            player.pause()
        }
    }
    
    func resume() {
        if case .Paused(let item) = state {
            state = .Playing(item)
            player.play()
        }
    }
    
    func stop() {
        state = .NotPlaying
        player.stop()
    }
    
    func skip() {
        if case .NotPlaying = state { return }
        player.skipToNextItem()
        if let track = player.nowPlayingItem {
            switch state {
            case .Playing: state = .Playing(track)
            case .Paused : state = .Paused(track)
            default: state = .NotPlaying
            }
        }
        if case .Paused = state {
            player.currentPlaybackTime = 0
        }
    }
    
    func previous() {
        if case .NotPlaying = state { return }
        if let track = player.nowPlayingItem {
            let trackIndex = player.indexOfNowPlayingItem
            let toPrevious = player.currentPlaybackTime < 2 && trackIndex != 0
            switch (state, toPrevious) {
            case (.Playing, true):
                player.skipToPreviousItem()
                player.currentPlaybackTime = 0
                state = .Playing(track)
            case (.Playing, false):
                player.skipToBeginning()
            case (.Paused, true):
                player.skipToPreviousItem()
                player.currentPlaybackTime = 0
                state = .Paused(track)
            case (.Paused, false):
                player.skipToBeginning()
            case (.NotPlaying, _): return
            }
        }
    }
    
    @objc private func nowPlayingStateDidChange() {
        if let item = player.nowPlayingItem {
            if case .playing = player.playbackState {
                state = .Playing(item)
            } else if case .paused = player.playbackState {
                state = .Paused(item)
            } else if case .stopped = player.playbackState {
                state = .NotPlaying
            }
        }
    }
    
    @objc private func playbackStateDidChange() {
        if case .stopped = player.playbackState {
            state = .NotPlaying
        } else if case .paused = player.playbackState, state.case != .Paused {
            guard let item = player.nowPlayingItem else {
                state = .NotPlaying
                return
            }
            state = .Paused(item)
        } else if case .playing = player.playbackState, state.case != .Playing {
            guard let item = player.nowPlayingItem else {
                state = .NotPlaying
                return
            }
            state = .Playing(item)
        }
    }
}

/// Code courtesy of: https://www.swiftbysundell.com/articles/observers-in-swift-part-1/
private extension AudioPlayer {
    func stateDidChange() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            switch state {
            case .NotPlaying:
                observer.audioPlayerDidStop(self)
            case .Playing(let item):
                observer.audioPlayer(self, didStartPlaying: item)
            case .Paused(let item):
                observer.audioPlayer(self, didPausePlaybackOf: item)
            }
        }
    }
    
    func shuffleStateDidChange() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.audioPlayer(self, didChangeShuffleStateTo: isShuffling)
        }
    }
    
    func repeatStateDidChange() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.audioPlayer(self, didChangeRepeatStateTo: isRepeating)
        }
    }
    
    struct Observation {
        weak var observer: AudioPlayerObserver?
    }
}

extension AudioPlayer {
    func addObserver(_ observer: AudioPlayerObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: AudioPlayerObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

protocol AudioPlayerObserver: class {
    func audioPlayer(_ player: AudioPlayer, didStartPlaying item: MPMediaItem)

    func audioPlayer(_ player: AudioPlayer, didPausePlaybackOf item: MPMediaItem)

    func audioPlayerDidStop(_ player: AudioPlayer)
    
    func audioPlayer(_ player: AudioPlayer, didChangeShuffleStateTo state: Bool)
    
    func audioPlayer(_ player: AudioPlayer, didChangeRepeatStateTo state: Bool)
}

extension AudioPlayerObserver {
    func audioPlayer(_ player: AudioPlayer, didStartPlaying item: MPMediaItem) {}

    func audioPlayer(_ player: AudioPlayer, didPausePlaybackOf item: MPMediaItem) {}

    func audioPlayerDidStop(_ player: AudioPlayer) {}
    
    func audioPlayer(_ player: AudioPlayer, didChangeShuffleStateTo state: Bool) {}
    
    func audioPlayer(_ player: AudioPlayer, didChangeRepeatStateTo state: Bool) {}
}
