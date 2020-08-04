//
//  Extensions.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

extension Double {
    /// Code courtesy of Alessandro Francucci on StackOverflow
    /// https://stackoverflow.com/questions/32022438/how-to-prevent-scientific-notation-with-float-in-swift
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." {
                string = String(string.dropLast())
                break
            }
            string = String(string.dropLast())
        }
        return string
    }
}

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
    
    /// Code courtesy of iamjason on Gist
    /// https://gist.github.com/iamjason/a0a92845094f5b210cf8
    func tintWithColor(color:UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()

        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -self.size.height)

        // multiply blend mode
        context?.setBlendMode(.multiply)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)

        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension MPMediaPlaylist {
    /// Code courtesy of Stephen Bodnar on Vaporforums.io
    /// https://www.vaporforums.io/viewThread/55
    var folderItems: [MPMediaPlaylist] {
        var allFolderItems = [MPMediaPlaylist]()
        if let playlists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist], let id = value(forProperty: "persistentID") as? Int  {
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
