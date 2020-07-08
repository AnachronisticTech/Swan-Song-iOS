//
//  Group.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation
import MediaPlayer

struct Group: Comparable {
    init(_ name: String, _ items: [MPMediaItem]) {
        self.name = name
        self.items = items
    }
    
    init(name: String, items: [MPMediaItem]) {
        self.name = name
        self.items = items
    }
    
    var name: String
    var items: [MPMediaItem]
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func < (lhs: Group, rhs: Group) -> Bool {
        return lhs.name < rhs.name
    }
}
