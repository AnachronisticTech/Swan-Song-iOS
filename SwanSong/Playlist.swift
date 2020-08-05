//
//  Playlist.swift
//  SwanSong
//
//  Created by Daniel Marriner on 31/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreData

@objc(Playlist)
class Playlist: NSManagedObject {
    
    @NSManaged var persistentID: Int64
    @NSManaged var title: String
    @NSManaged var items: [Int64]
    @NSManaged var folderItems: [Int64]
    @NSManaged var isLocalItem: Bool
    @NSManaged var isHidden: Bool
    @NSManaged var isFolder: Bool
    @NSManaged var parentPersistentID: Int64
    
    func hide() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        isHidden = true
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete list with id \(persistentID). \(error)")
        }
    }
    
}

@objc(Int64ArrayTransformer)
class Int64ArrayTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        return try! NSKeyedArchiver.archivedData(withRootObject: value!, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let value = value as? Data, let data = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(value) as? [Int64] {
            return data
        }
        return nil
    }
    
}
