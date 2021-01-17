//
//  SwanSongCollectionViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 28/11/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SwanSongCollectionViewController: UICollectionViewController, SwanSongController {
    @IBOutlet weak var swapViewButton: UIBarButtonItem!
    
    var collections = [MPMediaItemCollection]()
    var sections = [MPMediaQuerySection]()
    var selected = -1

    private var identifier: String {
        guard let title = navigationItem.title else { fatalError() }
        return String(title.lowercased().dropLast())
    }

    var isCollectionViewVisible = false {
        willSet {
            DispatchQueue.main.async { [self] in
                collectionView.reloadData()
                collectionView.setCollectionViewLayout(newValue ? flowLayout : listLayout, animated: false)
                collectionView.collectionViewLayout.invalidateLayout()
            }
            UserDefaults.standard.set(newValue, forKey: "\(identifier)LibraryIsCollectionViewVisible")
            swapViewButton.image = UIImage(named: newValue ? "list" : "grid")
        }
    }

    var flowLayout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let itemsPerRow = 2
        let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        layout.sectionInset = sectionInsets
        layout.minimumLineSpacing = sectionInsets.left
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: 0, height: 28)
        let padding = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        layout.itemSize = CGSize(width: widthPerItem, height: widthPerItem + 50)
        return layout
    }

    var listLayout: CustomFlowLayout {
        let layout = CustomFlowLayout()
        layout.sectionInsetReference = .fromContentInset
        layout.sectionHeadersPinToVisibleBounds = true
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 15)
        layout.headerReferenceSize = CGSize(width: 0, height: 28)
        return layout
    }

    @IBAction func swapView(_ sender: Any) {
        isCollectionViewVisible = !isCollectionViewVisible
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isAccessibilityElement = false

        /// Set collection view data
        collectionView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "ArtDetailCollectionRowMedium", bundle: nil), forCellWithReuseIdentifier: "row")
        collectionView.register(
            UINib(nibName: "CollectionViewHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )

        /// Set view to list or collection based on last selection
        isCollectionViewVisible = UserDefaults.standard.bool(forKey: "\(identifier)LibraryIsCollectionViewVisible")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTheme()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = collections[selected].representativeItem!.albumPersistentID
            destinationViewController.albumID = albumID
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .dark {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = darkTint
        } else {
            (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = lightTint
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError("Invalid element kind") }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath) as? CollectionViewHeader
            else { fatalError("Invalid view type") }

        header.title.text = sections[indexPath.section].title
        header.isAccessibilityElement = false
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].range.length
    }

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return sections.map({ $0.title })
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: isCollectionViewVisible ? "cell" : "row", for: indexPath) as! ArtDetailCollectionViewCell
        let index = sections[indexPath.section].range.lowerBound + indexPath.row
        cell.title?.text = collections[index].representativeItem?.albumTitle ?? ""
        cell.detail?.text = collections[index].representativeItem?.albumArtist ?? ""
        cell.artwork?.image = collections[index].representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
        cell.isAccessibilityElement = true
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = sections[indexPath.section].range.lowerBound + indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

/// Code courtesy of Imanou Petit on StackOverflow
/// https://stackoverflow.com/questions/44187881/uicollectionview-full-width-cells-allow-autolayout-dynamic-height
final class CustomFlowLayout: UICollectionViewFlowLayout {
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
