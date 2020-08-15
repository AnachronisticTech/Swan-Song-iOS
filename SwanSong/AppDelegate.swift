//
//  AppDelegate.swift
//  SwanSong
//
//  Created by Daniel Marriner on 03/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

let Player = AudioPlayer()
let Formatter = DateComponentsFormatter()

var lightTint: UIColor = TintColor.Blue.color
var darkTint : UIColor = TintColor.Blue.color

let filterLocal = MPMediaPropertyPredicate(
    value: false,
    forProperty: MPMediaItemPropertyIsCloudItem
)

var isInSnapshotMode = false

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
        
        let query = MPMediaQuery.playlists()
        query.addFilterPredicate(filterLocal)
        let lists = (query.collections ?? []) as! [MPMediaPlaylist]
        lists.forEach { save($0) }
        
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") { isInSnapshotMode = true }
        
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
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SwanSong")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ list: MPMediaPlaylist) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "persistentID = %ld", Int64(bitPattern: list.persistentID))
        if let results = try? managedContext.fetch(fetchRequest), results.count == 0 {
            let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)!
            let playlist = NSManagedObject(entity: entity, insertInto: managedContext)
            playlist.setValue(Int64(bitPattern: list.persistentID), forKey: "persistentID")
            playlist.setValue(list.title ?? "", forKey: "title")
            playlist.setValue(false, forKey: "isLocalItem")
            playlist.setValue(false, forKey: "isHidden")
            playlist.setValue(list.isFolder, forKey: "isFolder")
            playlist.setValue(list.value(forProperty: "parentPersistentID") as? Int, forKey: "parentPersistentID")
            playlist.setValue(list.items.map({ Int64(bitPattern: $0.persistentID) }), forKey: "items")
            playlist.setValue(list.folderItems.map({ Int64(bitPattern: $0.persistentID) }), forKey: "folderItems")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update and save. \(error)")
            }
        }
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

