//
//  SettingsViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 19/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var changeThemeModeControl: UISegmentedControl!
    
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
    
    func setTheme() {
        if #available(iOS 13.0, *), let theme = UserDefaults.standard.value(forKey: "theme") as? String {
            switch theme {
            case "light":
                changeThemeModeControl.selectedSegmentIndex = 1
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .light
            case "dark" :
                changeThemeModeControl.selectedSegmentIndex = 2
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .dark
            default:
                changeThemeModeControl.selectedSegmentIndex = 0
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .unspecified
            }
        } else {
            changeThemeModeControl.isEnabled = false
        }
    }
    
    @IBAction func changeThemeMode(_ sender: UISegmentedControl) {
        if #available(iOS 13.0, *) {
            switch sender.selectedSegmentIndex {
            case 1:
                UserDefaults.standard.set("light", forKey: "theme")
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .light
            case 2:
                UserDefaults.standard.set("dark", forKey: "theme")
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .dark
            default:
                UserDefaults.standard.set("auto", forKey: "theme")
                UIApplication.shared.windows.first!.rootViewController?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
}
