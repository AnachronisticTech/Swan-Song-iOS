//
//  Extensions.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

extension Optional where Wrapped == String {
    mutating func consume() -> String {
        let tmp = self ?? ""
        self = nil
        return tmp
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension MPMediaPlaylist {
    /// Code courtesy of Stephen Bodnar on Vaporforums.io
    /// https://www.vaporforums.io/viewThread/55
    var folderItems: [MPMediaPlaylist] {
        var allFolderItems = [MPMediaPlaylist]()
        let query = MPMediaQuery.playlists()
        query.addFilterPredicate(filterLocal)
        if let playlists = query.collections as? [MPMediaPlaylist], let id = value(forProperty: "persistentID") as? Int {
            for playlist in playlists {
                if let parentId = playlist.value(forProperty: "parentPersistentID") as? Int {
                    if parentId != 0 && parentId == id {
                        allFolderItems.append(playlist)
                    }
                }
            }
        }
        return allFolderItems
    }
    
    var isFolder: Bool {
        self.value(forProperty: "isFolder") as! Bool
    }
    
    var title: String? {
        self.value(forProperty: MPMediaPlaylistPropertyName) as? String
    }
}
