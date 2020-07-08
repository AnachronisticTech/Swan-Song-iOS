//
//  UserInterface.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class NumberDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
}

class ArtDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
}

class ArtDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
}

class CollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var title: UILabel!
}

class FooterTableViewCell: UITableViewCell {
    @IBOutlet weak var footer: UILabel!
}

//class PlaylistSongTableViewCell: UITableViewCell {
//    @IBOutlet weak var albumArtwork: UIImageView!
//    @IBOutlet weak var trackTitle: UILabel!
//    @IBOutlet weak var trackDuration: UILabel!
////    @IBOutlet weak var albumArtist: UILabel!
//}

@IBDesignable class RoundedArtwork: UIImageView {
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
        let height: CGFloat = 10
        let origin = CGPoint(x: bounds.minX, y: bounds.midY - (height / 2))
        return CGRect(origin: origin, size: CGSize(width: bounds.width, height: height))
    }
}
