//
//  UserInterface.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumArtist: UILabel!
}

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var albumArtist: UILabel!
}

class AlbumCollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var headerTitle: UILabel!
}

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
}

class FooterTableViewCell: UITableViewCell {
    @IBOutlet weak var footer: UILabel!
}

class PlaylistSongTableViewCell: UITableViewCell {
    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
//    @IBOutlet weak var albumArtist: UILabel!
}

@IBDesignable class LargeArtwork: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

@IBDesignable class RoundedButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 10 {
       didSet {
           layer.cornerRadius = cornerRadius
       }
   }
}

@IBDesignable class AudioTrack: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let h: CGFloat = 10
        let point = CGPoint(x: bounds.minX, y: bounds.midY - (h/2))
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: h))
    }
}
