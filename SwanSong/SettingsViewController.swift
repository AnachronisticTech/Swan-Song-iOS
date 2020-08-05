//
//  SettingsViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 19/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SettingsViewController: UITableViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var changeThemeModeControl: UISegmentedControl!
    @IBOutlet weak var lightModePicker: UIPickerView!
    @IBOutlet weak var lightModeLabel: UILabel!
    var lightModePickerVisible = false
    @IBOutlet weak var darkModePicker: UIPickerView!
    @IBOutlet weak var darkModeLabel: UILabel!
    var darkModePickerVisible = false
    @IBOutlet weak var closeButtonSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setTheme()
        
        lightModePicker.isHidden = true
        lightModePicker.delegate = self
        lightModePicker.dataSource = self
        lightModePicker.translatesAutoresizingMaskIntoConstraints = false
        lightModePicker.selectRow(TintColor.allCases.firstIndex(where: { $0.color == lightTint }) ?? 0, inComponent: 0, animated: false)
        lightModeLabel.text = TintColor.allCases.first(where: { $0.color == lightTint })?.rawValue ?? "Blue"
        
        darkModePicker.isHidden = true
        darkModePicker.delegate = self
        darkModePicker.dataSource = self
        darkModePicker.translatesAutoresizingMaskIntoConstraints = false
        darkModePicker.selectRow(TintColor.allCases.firstIndex(where: { $0.color == darkTint }) ?? 0, inComponent: 0, animated: false)
        darkModeLabel.text = TintColor.allCases.first(where: { $0.color == darkTint })?.rawValue ?? "Blue"
        
        if #available(iOS 13.0, *) {
            closeButtonSwitch.isOn = UserDefaults.standard.bool(forKey: "playerCloseButtonIsVisible")
        } else {
            changeThemeModeControl.isEnabled = false
            tableView.cellForRow(at: IndexPath(row: 3, section: 1))?.isUserInteractionEnabled = false
            closeButtonSwitch.isEnabled = false
            closeButtonSwitch.isOn = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .dark {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
        } else {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
        }
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
            setTint()
        }
    }
    
    func showPicker(_ picker: UIPickerView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            picker.alpha = 1
        }) { _ in
            picker.isHidden = false
        }
    }
    
    func hidePicker(_ picker: UIPickerView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            picker.alpha = 0
        }) { _ in
            picker.isHidden = true
        }
    }
    
    func setTint() {
        if let theme = UserDefaults.standard.value(forKey: "theme") as? String {
            if theme == "light" {
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
            } else if theme == "dark" {
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
            } else {
                if traitCollection.userInterfaceStyle == .light {
                    (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
                } else {
                    (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
                }
            }
        } else {
            if traitCollection.userInterfaceStyle == .light {
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
            } else {
                (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
            }
        }
    }
    
    @IBAction func reauthorise(_ sender: Any) {
        if MPMediaLibrary.authorizationStatus() == .authorized {
            let alert = UIAlertController(
                title: "Already Authorised",
                message: "SwanSong is already authorised to access your iTunes media library.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                title: "Ok",
                style: .default
            ))
            present(alert, animated: true)
        } else if MPMediaLibrary.authorizationStatus() == .denied {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    @IBAction func resetWarnings(_ sender: Any) {
        let alert = UIAlertController(
            title: "Warnings Reset",
            message: "All warnings have been reset.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "playlistModificationWarningHasBeenShown")
        })
        present(alert, animated: true)
    }
    
    @IBAction func setCloseButtonVisibility(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "playerCloseButtonIsVisible")
    }
    
}

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = tableView.rowHeight
        if indexPath.row == 2 {
            height = lightModePickerVisible ? 216 : 0
        } else if indexPath.row == 4 {
            height = darkModePickerVisible ? 216 : 0
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
            case (0, 1):
                if lightModePickerVisible {
                    lightModePickerVisible = false
                    hidePicker(lightModePicker)
                } else {
                    lightModePickerVisible = true
                    showPicker(lightModePicker)
                    darkModePickerVisible = false
                    hidePicker(darkModePicker)
                }
            case (0, 3):
                if #available(iOS 13.0, *) {
                    if darkModePickerVisible {
                        darkModePickerVisible = false
                        hidePicker(darkModePicker)
                    } else {
                        darkModePickerVisible = true
                        showPicker(darkModePicker)
                        lightModePickerVisible = false
                        hidePicker(lightModePicker)
                    }
                }
            default:
                return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SettingsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TintColor.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        TintColor.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if lightModePickerVisible {
            UserDefaults.standard.set(TintColor.allCases[row].rawValue, forKey: "light")
            lightModeLabel.text = TintColor.allCases[row].rawValue
            lightTint = TintColor.allCases[row].color
        } else {
            UserDefaults.standard.set(TintColor.allCases[row].rawValue, forKey: "dark")
            darkModeLabel.text = TintColor.allCases[row].rawValue
            darkTint = TintColor.allCases[row].color
        }
        setTint()
    }
    
}
