//
//  SwanSongViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 19/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class SwanSongViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = false

        setTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setTheme()
    }
    
    private func setTheme() {
        if #available(iOS 13.0, *), let theme = UserDefaults.standard.value(forKey: "theme") as? String {
            switch theme {
            case "light":
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .light
                navigationController?.navigationBar.overrideUserInterfaceStyle = .light
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
            case "dark" :
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .dark
                navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
            default:
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .unspecified
                navigationController?.navigationBar.overrideUserInterfaceStyle = .unspecified
                if traitCollection.userInterfaceStyle == .dark {
                    (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
                } else {
                    (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
                }
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .dark {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
        } else {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
        }
    }
    
}
