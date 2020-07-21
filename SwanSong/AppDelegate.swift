//
//  AppDelegate.swift
//  SwanSong
//
//  Created by Daniel Marriner on 03/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

let Player = AudioPlayer()
let Formatter = DateComponentsFormatter()

var lightTint: UIColor = TintColor.Blue.color
var darkTint : UIColor = TintColor.Blue.color

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Formatter.allowedUnits = [.minute, .second]
        Formatter.unitsStyle = .positional
        Formatter.zeroFormattingBehavior = .pad
        
        if UserDefaults.standard.value(forKey: "theme") == nil {
            UserDefaults.standard.set("auto", forKey: "theme")
        }
        
        if let light = UserDefaults.standard.value(forKey: "light") as? String {
            lightTint = TintColor.init(rawValue: light)!.color
        } else {
            UserDefaults.standard.set("Blue", forKey: "light")
        }
        if let dark = UserDefaults.standard.value(forKey: "dark") as? String {
            darkTint = TintColor.init(rawValue: dark)!.color
        } else {
            UserDefaults.standard.set("Blue", forKey: "dark")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
    
func checkAuthorisation(_ viewController: UIViewController, then run: (() -> Void)? = nil) {
    if MPMediaLibrary.authorizationStatus() != .authorized {
        MPMediaLibrary.requestAuthorization { status in
            if status != .authorized {
                let alert = UIAlertController(
                    title: "Not Authorised",
                    message: "Swan Song is not authorised to access your iTunes media library. To authorise, please go to the in-app settings page to re-request authorisation.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                    title: "Ok",
                    style: .cancel,
                    handler: nil)
                )
                DispatchQueue.main.async {
                    viewController.present(alert, animated: true)
                }
            } else if let run = run {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    run()
                }
            }
        }
    }
    if let run = run { run() }
}

