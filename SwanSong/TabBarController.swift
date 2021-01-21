//
//  TabBarController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer
import LNPopupController

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if let order = UserDefaults.standard.value(forKey: "globalControllerOrder") as? [Int] {
            var reordered = [UIViewController]()
            if let items = viewControllers {
                for tag in order {
                    for item in items {
                        if item.tabBarItem.tag == tag {
                            reordered.append(item)
                        }
                    }
                }
            }
            setViewControllers(reordered, animated: false)
        }

        Player.addObserver(self)

        self.popupBar.progressViewStyle = .bottom
        self.popupBar.marqueeScrollEnabled = true
        self.popupContentView.popupCloseButtonStyle = .none
        switch Player.state {
            case .Playing(let item), .Paused(let item):
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "player") else { return }
                controller.popupItem.title = item.title
                controller.popupItem.subtitle = "\(item.albumTitle ?? "Unknown Album") - \(item.artist ?? "Unknown Artist")"
                controller.popupItem.image = item.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
//                controller.popupItem.progress = 0.3
                self.presentPopupBar(withContentViewController: controller, animated: true)
            case .NotPlaying:
                self.dismissPopupBar(animated: true)
        }
//        MPNowPlayingInfoCenter.default().nowPlayingInfo?[.MPNowPlayingInfoPropertyElapsedPlaybackTime]
    }
    
    override func tabBar(_ tabBar: UITabBar, didEndCustomizing items: [UITabBarItem], changed: Bool) {
        var order = [Int]()
        
        if let items = viewControllers {
            for item in items {
                order.append(item.tabBarItem.tag)
            }
        }
        
        UserDefaults.standard.set(order, forKey: "globalControllerOrder")
    }
}

extension TabBarController: AudioPlayerObserver {
    func audioPlayer(_ player: AudioPlayer, didStartPlaying item: MPMediaItem) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "player") else { return }
        controller.popupItem.title = item.title
        controller.popupItem.subtitle = "\(item.albumTitle ?? "Unknown Album") - \(item.artist ?? "Unknown Artist")"
        controller.popupItem.image = item.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
        self.presentPopupBar(withContentViewController: controller, animated: true)
    }
}
