//
//  SwappableViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 11/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SwappableViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var swapViewButton: UIBarButtonItem!
    
    let itemsPerRow = 2
    let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    private var identifier: String {
        guard let title = navigationItem.title else { fatalError() }
        return String(title.lowercased().dropLast())
    }
    
    var isCollectionViewVisible = false {
        willSet {
            newValue ? view.sendSubviewToBack(listView) : view.bringSubviewToFront(listView)
            UserDefaults.standard.set(newValue, forKey: "\(identifier)LibraryIsCollectionViewVisible")
            swapViewButton.image = UIImage(named: newValue ? "list" : "grid")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.tableFooterView = UIView()
        
        gridView.delegate = self
        let layout = gridView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        layout?.headerReferenceSize = CGSize(width: 0, height: 28)
        
        /// Set view to list or collection based on last selection
        isCollectionViewVisible = UserDefaults.standard.value(forKey: "\(identifier)LibraryIsCollectionViewVisible") as? Bool ?? false
    }
    
    @IBAction func swapView(_ sender: Any) {
        isCollectionViewVisible = !isCollectionViewVisible
    }
    
}

extension SwappableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
