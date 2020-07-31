//
//  Playlist.swift
//  SwanSong
//
//  Created by Daniel Marriner on 31/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation
import CoreData

@objc(Playlist)
class Playlist: NSManagedObject {
    
    @NSManaged var persistentID: Int64
    @NSManaged var title: String
    @NSManaged var tracks: [Int64]
    
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
