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
    @IBOutlet private weak var folderOverlay: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    
    private var action: (() -> Void)? = nil
    private var state = true
    
    var isFolderOverlayVisible = false {
        willSet {
            folderOverlay.isHidden = !newValue
        }
    }
    
    var showsEditControl: Bool = false {
        willSet {
            editButton.isUserInteractionEnabled = newValue
            editButtonHeight.constant = newValue ? 30 : 0
            editButtonWidth.constant = newValue ? 46 : 0
        }
    }
    
    func setEditAction(_ closure: @escaping () -> Void) {
        action = closure
    }
    
    @IBAction func editAction(_ sender: Any) {
        if let action = action {
            state = !state
            editButton.setTitle(state ? "Edit" : "Done", for: .normal)
            action()
        }
    }
}

class SingleArtDetailTableViewCell: ArtDetailTableViewCell {
    @IBOutlet weak var artwork: UIImageView!
}

class MultiArtDetailTableViewCell: ArtDetailTableViewCell {
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

    /// Code courtesy of Imanou Petit on StackOverflow
    /// https://stackoverflow.com/questions/44187881/uicollectionview-full-width-cells-allow-autolayout-dynamic-height
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
    }
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

/// Code courtesy of Imanou Petit on StackOverflow
/// https://stackoverflow.com/questions/44187881/uicollectionview-full-width-cells-allow-autolayout-dynamic-height
final class ListFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach({ layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            }
        })
        return layoutAttributesObjects
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            fatalError()
        }
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return layoutAttributes
    }
}
