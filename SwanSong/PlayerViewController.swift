//
//  PlayerViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 05/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: SwanSongViewController {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var bigArtwork: UIImageView!
    @IBOutlet weak var scrubber: UISlider!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackInfo: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var volumeSlider: MPVolumeView!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    
    var timer = Timer()
    var isMovingScrubber = false
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let elementHeights: CGFloat = (
//            artwork.frame.height
//            + scrubber.superview!.frame.height
//            + trackTitle.frame.height
//            + trackInfo.frame.height
//            + playButton.superview!.frame.height
//        )
//        preferredContentSize.height = (
//            elementHeights
//            + 25 // artwork top+bottom constraints
//            + 8  // label-controlls margin
//        )
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Set view theme
        if #available(iOS 13.0, *) {
            closeButtonHeight.constant = UserDefaults.standard.bool(forKey: "playerCloseButtonIsVisible") ? 49 : 0
            if let theme = UserDefaults.standard.value(forKey: "theme") as? String {
                switch theme {
                    case "light": overrideUserInterfaceStyle = .light
                    case "dark" : overrideUserInterfaceStyle = .dark
                    default: overrideUserInterfaceStyle = .unspecified
                }
            }
        }
        
        /// Set view controller as observer of AudioPlayer state
        Player.addObserver(self)
        
        /// Set up time scrubber and labels
        scrubber.isContinuous = false
        scrubber.setThumbImage(UIImage(color: adaptiveColor(lightTint, darkTint), size: CGSize(width: 1, height: 6)), for: .normal)
        scrubber.setMinimumTrackImage(UIImage(color: adaptiveColor(lightTint, darkTint), size: CGSize(width: 5, height: 3)), for: .normal)
        if #available(iOS 13.0, *) {
            scrubber.setMaximumTrackImage(UIImage(color: adaptiveColor(.systemGray5, .systemGray), size: CGSize(width: 5, height: 3)), for: .normal)
        } else {
            scrubber.setMaximumTrackImage(UIImage(color: .lightGray, size: CGSize(width: 5, height: 3)), for: .normal)
        }
        currentTime.textColor = adaptiveColor(.darkGray, .lightGray)
        remainingTime.textColor = adaptiveColor(.darkGray, .lightGray)
        trackInfo.textColor = adaptiveColor(.darkGray, .lightGray)
        shuffleButton.backgroundColor = Player.isShuffling ? adaptiveColor(lightTint, darkTint) : .clear
        shuffleButton.setImage(UIImage(named: Player.isShuffling ? "shuffle_inverted" : "shuffle"), for: .normal)
        repeatButton.backgroundColor = Player.isRepeating ? adaptiveColor(lightTint, darkTint) : .clear
        repeatButton.setImage(UIImage(named: Player.isRepeating ? "repeat_inverted" : "repeat"), for: .normal)
        
        /// Set initial user interface elements and track details
        timer.invalidate()
        updateView()
        
        /// TESTING: Disable timer when in simulator
        if isInSnapshotMode {
            timer.invalidate()
            if case .Playing(let item) = Player.state {
                scrubber.value = 0.45
                let time = TimeInterval(scrubber.value) * item.playbackDuration
                currentTime.text = Formatter.string(from: time)
                remainingTime.text = Formatter.string(from: item.playbackDuration - time)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// Set up view update timer
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateView),
            userInfo: nil,
            repeats: true
        )
    }
    
    /// Invalidate the timer when view disappears to avoid memory leaks
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    
    /// Update view based on `Player` state
    @objc func updateView() {
        switch Player.state {
        case .Playing(let item):
            setViewContents(for: item)
            playButton.setImage(UIImage(named: "pause_fill"), for: .normal)
        case .Paused(let item):
            setViewContents(for: item)
            playButton.setImage(UIImage(named: "play_fill"), for: .normal)
        case .NotPlaying:
            title = "Not Playing"
            currentTime.text = "00:00"
            remainingTime.text = "00:00"
            artwork.image =  UIImage(named: "blank_artwork")
            bigArtwork.image =  UIImage(named: "blank_artwork")
            scrubber.setValue(0, animated: false)
            playButton.setImage(UIImage(named: "play_fill"), for: .normal)
        }
    }
    
    /// Set track details and user interface elements
    private func setViewContents(for item: MPMediaItem) {
        // Update artwork and labels
        artwork.image = item.artwork?.image(at: CGSize(width: 1000, height: 1000)) ?? UIImage(named: "blank_artwork")
        bigArtwork.image = item.artwork?.image(at: CGSize(width: 1000, height: 1000)) ?? UIImage(named: "blank_artwork")
        trackTitle.text = item.title
        trackInfo.text = "\(item.artist ?? (item.albumArtist ?? "")) - \(item.albumTitle ?? "")"

        // Update times and scrubber
        if isMovingScrubber {
            let time = TimeInterval(scrubber.value) * item.playbackDuration
            currentTime.text = Formatter.string(from: time)
            remainingTime.text = Formatter.string(from: item.playbackDuration - time)
        } else {
            currentTime.text = Formatter.string(from: Player.currentTime)
            remainingTime.text = Formatter.string(from: item.playbackDuration - Player.currentTime)
            scrubber.setValue(Float(Player.currentTime / item.playbackDuration), animated: false)
        }
    }
    
    @IBAction func scrubberStartedEditing(_ sender: Any) {
        isMovingScrubber = true
    }
    
    /// Set track current time to new scrubber location
    @IBAction func scrubberEndedEditing(_ sender: Any) {
        switch Player.state {
        case .Playing(let track), .Paused(let track):
            Player.currentTime = TimeInterval(scrubber.value) * track.playbackDuration
        default: break
        }
        isMovingScrubber = false
    }
    
    @IBAction func `repeat`(_ sender: Any) {
        if case .NotPlaying = Player.state { return }
        Player.isRepeating = !Player.isRepeating
    }
    
    @IBAction func previousTrack(_ sender: Any) { Player.previous() }
    
    @IBAction func playPause(_ sender: Any) {
        if isInSnapshotMode {
            dismiss(animated: true)
            return
        }
        
        if case .Playing = Player.state {
            Player.pause()
        } else if case .Paused = Player.state {
            Player.resume()
        }
    }
    
    @IBAction func skipTrack(_ sender: Any) { Player.skip() }
    
    @IBAction func shuffle(_ sender: Any) {
        if case .NotPlaying = Player.state { return }
        Player.isShuffling = !Player.isShuffling
    }
    
    /// Select colour based on UI theme or user preferece
    private func adaptiveColor(_ light: UIColor, _ dark: UIColor) -> UIColor {
        if case .dark = traitCollection.userInterfaceStyle {
            return dark
        }
        return light
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            scrubber.setMaximumTrackImage(UIImage(color: adaptiveColor(.systemGray5, .systemGray), size: CGSize(width: 5, height: 3)), for: .normal)
        }
        scrubber.setThumbImage(UIImage(color: adaptiveColor(lightTint, darkTint), size: CGSize(width: 1, height: 6)), for: .normal)
        scrubber.setMinimumTrackImage(UIImage(color: adaptiveColor(lightTint, darkTint), size: CGSize(width: 5, height: 3)), for: .normal)
        currentTime.textColor = adaptiveColor(.darkGray, .lightGray)
        remainingTime.textColor = adaptiveColor(.darkGray, .lightGray)
        trackInfo.textColor = adaptiveColor(.darkGray, .lightGray)
        
        let isShuffling = Player.isShuffling
        Player.isShuffling = isShuffling
        let isRepeating = Player.isRepeating
        Player.isRepeating = isRepeating
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PlayerViewController: AudioPlayerObserver {
    func audioPlayer(_ player: AudioPlayer, didChangeShuffleStateTo state: Bool) {
        shuffleButton.backgroundColor = state ? adaptiveColor(lightTint, darkTint) : .clear
        shuffleButton.setImage(UIImage(named: state ? "shuffle_inverted" : "shuffle"), for: .normal)
    }
    
    func audioPlayer(_ player: AudioPlayer, didChangeRepeatStateTo state: Bool) {
        repeatButton.backgroundColor = state ? adaptiveColor(lightTint, darkTint) : .clear
        repeatButton.setImage(UIImage(named: state ? "repeat_inverted" : "repeat"), for: .normal)
    }
}
