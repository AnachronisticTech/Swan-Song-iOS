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
    
    @IBOutlet weak var albumListView: UITableView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    var albumLibrary: [MPMediaItemCollection] = []
    var selected: (Int, Int) = (-1, -1)
    
    private let itemsPerRow = 2
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    var isCollectionViewVisible = false {
        willSet {
            newValue ? view.sendSubviewToBack(albumListView) : view.bringSubviewToFront(albumListView)
            UserDefaults.standard.set(newValue, forKey: "albumLibraryIsCollectionViewVisible")
        }
    }

    struct Group: Comparable {
        internal init(initial: Character, albums: [MPMediaItem]) {
            self.initial = initial
            self.albums = albums
        }
        
        var initial: Character
        var albums: [MPMediaItem]
        
        static func == (lhs: Group, rhs: Group) -> Bool {
            return lhs.initial == rhs.initial
        }
        
        static func < (lhs: Group, rhs: Group) -> Bool {
            return lhs.initial < rhs.initial
        }
    }
    
    var albumGroups: [Group] {
        var tmp: [Group] = []
        albumLibrary.forEach { item in
            let firstLetter = item.items[0].albumTitle!.first!
            if var copy = tmp.first(where: { $0.initial == firstLetter }) {
                tmp.removeAll(where: { $0 == copy })
                copy.albums.append(item.items[0])
                tmp.append(copy)
            } else {
                tmp.append(Group(initial: firstLetter, albums: [item.items[0]]))
            }
        }
        tmp.sort(by: <)
        return tmp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        /// Load albums from library
        albumLibrary = MPMediaQuery.albums().collections ?? []
        
        /// Set list view data
        albumListView.delegate = self
        albumListView.dataSource = self
        albumListView.tableFooterView = UIView()
        albumListView.reloadData()
        
        /// Set collection view data
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        let layout = albumCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        albumCollectionView.reloadData()
        
        /// Set view to list or collection based on last selection
        isCollectionViewVisible = UserDefaults.standard.value(forKey: "albumLibraryIsCollectionViewVisible") as? Bool ?? false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = albumGroups[selected.0].albums[selected.1].albumPersistentID
            destinationViewController.albumID = albumID
        }
    }
    
    @IBAction func changeView(_ sender: Any) {
        isCollectionViewVisible = !isCollectionViewVisible
    }
}

extension AlbumLibraryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return albumGroups.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(albumGroups[section].initial)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumGroups[section].albums.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return albumGroups.map { String($0.initial) }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumTableViewCell = albumListView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! AlbumTableViewCell
        cell.albumTitle?.text = albumGroups[indexPath.section].albums[indexPath.row].albumTitle ?? ""
        cell.albumArtist?.text = albumGroups[indexPath.section].albums[indexPath.row].albumArtist ?? ""
        cell.albumArtwork?.image = albumGroups[indexPath.section].albums[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected.0 = indexPath.section
        selected.1 = indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        albumListView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AlbumLibraryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return albumGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as? AlbumCollectionViewHeader
                else { fatalError("Invalid view type") }
            
            header.headerTitle.text = String(albumGroups[indexPath.section].initial)
            return header
        default:
            assert(false, "Invalid element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumGroups[section].albums.count
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return albumGroups.map { String($0.initial) }
    }
    
    /// sectionForSectionIndexTitle (for alphabet scrubber)
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return index
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "album", for: indexPath) as! AlbumCollectionViewCell
        cell.albumTitle?.text = albumGroups[indexPath.section].albums[indexPath.row].albumTitle ?? ""
        cell.albumArtist?.text = albumGroups[indexPath.section].albums[indexPath.row].albumArtist ?? ""
        cell.albumArtwork?.image = albumGroups[indexPath.section].albums[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected.0 = indexPath.section
        selected.1 = indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        albumCollectionView.deselectItem(at: indexPath, animated: true)
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

