//
//  UserInterface.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
}

class NumberDetailTableViewCell: DetailTableViewCell {
    @IBOutlet weak var number: UILabel!
}

class ArtDetailTableViewCell: DetailTableViewCell {
    @IBOutlet weak var artwork: UIImageView!
}

class MultiArtDetailTableViewCell: DetailTableViewCell {
    @IBOutlet weak var artwork1: UIImageView!
    @IBOutlet weak var artwork2: UIImageView!
    @IBOutlet weak var artwork3: UIImageView!
    @IBOutlet weak var artwork4: UIImageView!
}

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
}

class ArtDetailCollectionViewCell: DetailCollectionViewCell {
    @IBOutlet weak var artwork: UIImageView!
}

class MultiArtDetailCollectionViewCell: DetailCollectionViewCell {
    @IBOutlet weak var artwork1: UIImageView!
    @IBOutlet weak var artwork2: UIImageView!
    @IBOutlet weak var artwork3: UIImageView!
    @IBOutlet weak var artwork4: UIImageView!
}

class CollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var title: UILabel!
}

class FooterTableViewCell: UITableViewCell {
    @IBOutlet weak var footer: UILabel!
}

@IBDesignable class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

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

enum TintColor: String, CaseIterable {
    case Red, Orange, Yellow, Green, Teal, Blue, Purple, Pink
    
    var color: UIColor {
        switch self {
        case .Red: return .systemRed
        case .Orange: return .systemOrange
        case .Yellow: return .systemYellow
        case .Green: return .systemGreen
        case .Teal: return .systemTeal
        case .Blue: return .systemBlue
        case .Purple: return .systemPurple
        case .Pink: return .systemPink
        }
    }
}
