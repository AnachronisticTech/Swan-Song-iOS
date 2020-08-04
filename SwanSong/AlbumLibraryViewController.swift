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

    var collections = [MPMediaItemCollection]()
    var sections = [MPMediaQuerySection]()
    var selected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised, then load library
        checkAuthorisation(self) { self.librarySetup() }
        
        /// Set list view data
        listView.dataSource = self
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "album")
        
        /// Set collection view data
        gridView.dataSource = self
        gridView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "album")
        gridView.register(
            UINib(nibName: "CollectionViewHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }
    
    /// Load albums from library
    func librarySetup() {
        let query = MPMediaQuery.albums()
        let filterLocal = MPMediaPropertyPredicate(
            value: false,
            forProperty: MPMediaItemPropertyIsCloudItem
        )
        query.addFilterPredicate(filterLocal)
        collections = query.collections ?? []
        sections = query.collectionSections ?? []
        
        listView.reloadData()
        gridView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = collections[selected].representativeItem!.albumPersistentID
            destinationViewController.albumID = albumID
        }
    }
    
}

extension AlbumLibraryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].range.length
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map({ $0.title })
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! SingleArtDetailTableViewCell
        let index = sections[indexPath.section].range.lowerBound + indexPath.row
        cell.title.text = collections[index].representativeItem?.albumTitle ?? ""
        cell.detail?.text = collections[index].representativeItem?.albumArtist ?? ""
        cell.artwork?.image = collections[index].representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = sections[indexPath.section].range.lowerBound + indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AlbumLibraryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as? CollectionViewHeader
                else { fatalError("Invalid view type") }
            
            header.title.text = sections[indexPath.section].title
            return header
        default:
            assert(false, "Invalid element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].range.length
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return sections.map({ $0.title })
    }
    
    /// sectionForSectionIndexTitle (for alphabet scrubber)
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return index
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "album", for: indexPath) as! ArtDetailCollectionViewCell
        let index = sections[indexPath.section].range.lowerBound + indexPath.row
        cell.title?.text = collections[index].representativeItem?.albumTitle ?? ""
        cell.detail?.text = collections[index].representativeItem?.albumArtist ?? ""
        cell.artwork?.image = collections[index].representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = sections[indexPath.section].range.lowerBound + indexPath.row
        performSegue(withIdentifier: "ToAlbum", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

