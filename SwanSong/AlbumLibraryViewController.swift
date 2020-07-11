//
//  AlbumLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 06/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumLibraryViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var swapViewButton: UIBarButtonItem!
    var library: [MPMediaItemCollection] = []
    var groups = [Group]()
    var selected: (Int, Int) = (-1, -1)
    
    private let itemsPerRow = 2
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    var isCollectionViewVisible = false {
        willSet {
            newValue ? view.sendSubviewToBack(listView) : view.bringSubviewToFront(listView)
            UserDefaults.standard.set(newValue, forKey: "albumLibraryIsCollectionViewVisible")
            swapViewButton.image = UIImage(named: newValue ? "list" : "grid")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        /// Load albums from library
        library = MPMediaQuery.albums().collections ?? []
        library.forEach { item in
            let firstLetter = String(item.items[0].albumTitle!.first!)
            if var copy = groups.first(where: { $0.name == firstLetter }) {
                groups.removeAll(where: { $0 == copy })
                copy.items.append(item.items[0])
                groups.append(copy)
            } else {
                groups.append(Group(firstLetter, [item.items[0]]))
            }
        }
        groups.sort(by: <)
        
        /// Set list view data
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "album")
        
        /// Set collection view data
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.reloadData()
        collectionView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "album")
        
        /// Set view to list or collection based on last selection
        isCollectionViewVisible = UserDefaults.standard.value(forKey: "albumLibraryIsCollectionViewVisible") as? Bool ?? false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = groups[selected.0].items[selected.1].albumPersistentID
            destinationViewController.albumID = albumID
        }
    }
    
    @IBAction func swapView(_ sender: Any) {
        isCollectionViewVisible = !isCollectionViewVisible
    }
}

extension AlbumLibraryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(groups[section].name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return groups.map { String($0.name) }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! ArtDetailTableViewCell
        cell.title?.text = groups[indexPath.section].items[indexPath.row].albumTitle ?? ""
        cell.detail?.text = groups[indexPath.section].items[indexPath.row].albumArtist ?? ""
        cell.artwork?.image = groups[indexPath.section].items[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected.0 = indexPath.section
        selected.1 = indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        listView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AlbumLibraryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as? CollectionViewHeader
                else { fatalError("Invalid view type") }
            
            header.title.text = String(groups[indexPath.section].name)
            return header
        default:
            assert(false, "Invalid element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return groups.map { String($0.name) }
    }
    
    /// sectionForSectionIndexTitle (for alphabet scrubber)
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return index
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ArtDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "album", for: indexPath) as! ArtDetailCollectionViewCell
        cell.title?.text = groups[indexPath.section].items[indexPath.row].albumTitle ?? ""
        cell.detail?.text = groups[indexPath.section].items[indexPath.row].albumArtist ?? ""
        cell.artwork?.image = groups[indexPath.section].items[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected.0 = indexPath.section
        selected.1 = indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension AlbumLibraryViewController: UICollectionViewDelegateFlowLayout {
    
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

