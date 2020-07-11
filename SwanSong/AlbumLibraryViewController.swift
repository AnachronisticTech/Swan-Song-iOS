//
//  AlbumLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 06/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumLibraryViewController: SwappableViewController {
    
    var library: [MPMediaItemCollection] = []
    var groups = [Group]()
    var selected: (Int, Int) = (-1, -1)
    
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
        listView.dataSource = self
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "album")
        
        /// Set collection view data
        collectionView.dataSource = self
        collectionView.reloadData()
        collectionView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "album")
        collectionView.register(
            UINib(nibName: "CollectionViewHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = groups[selected.0].items[selected.1].albumPersistentID
            destinationViewController.albumID = albumID
        }
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

