//
//  GenreLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class GenreLibraryViewController: SwappableViewController {

    /// Load genres from library
    var library = [MPMediaItemCollection]()
    var details = [(String, Int, [MPMediaItem])]()
    var selected: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised, then load library
        checkAuthorisation(self) { self.librarySetup() }
        
        /// Set list view data
        listView.dataSource = self
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "genre")
        listView.register(UINib(nibName: "MultiArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "genre_multi")
        
        /// Set collection view data
        gridView.dataSource = self
        gridView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "genre")
        gridView.register(UINib(nibName: "MultiArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "genre_multi")
        gridView.register(
            UINib(nibName: "CollectionViewHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }
    
    /// Load genres from library
    func librarySetup() {
        library = MPMediaQuery.genres().collections ?? []
        library.forEach { genre in
            let title = genre.items.first?.genre ?? ""
            var art = [MPMediaItem]()
            for track in genre.items.sorted(by: { $0.albumTitle! < $1.albumTitle! }) { // Sorting is slow
                if !art.contains(where: { $0.albumPersistentID == track.albumPersistentID }) {
                    art.append(track)
                }
                if art.count >= 4 { break }
            }
            details.append((title, genre.items.count, art))
        }
        
        listView.reloadData()
        gridView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGenre" {
            let destinationViewController = segue.destination as! MultiAlbumListViewController
            guard let genre = library.filter({ $0.items[0].genre == selected }).first else { return }
            destinationViewController.query = MPMediaQuery.genres()
            destinationViewController.persistentID = genre.persistentID
            destinationViewController.filterProperty = MPMediaItemPropertyGenrePersistentID
        }
    }
    
}

extension GenreLibraryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Set(details.map { $0.0.first! }).count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(Array(Set(details.map { $0.0.first! })).sorted(by: <)[section])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(Set(details.map { String($0.0.first!) })).sorted(by: <)[section].first!
        return details.filter({ $0.0.first! == key }).count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(Set(details.map { String($0.0.first!) })).sorted(by: <)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(Set(details.map { String($0.0.first!) })).sorted(by: <)[indexPath.section].first!
        let data = details.filter({ $0.0.first! == key })[indexPath.row]
        if data.2.count < 4 {
            let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "genre", for: indexPath) as! ArtDetailTableViewCell
            cell.title.text = data.0
            cell.detail?.text = "\(data.1) track\(data.1 == 1 ? "" : "s")"
            cell.artwork?.image = data.2.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        } else {
            let cell: MultiArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "genre_multi", for: indexPath) as! MultiArtDetailTableViewCell
            cell.title.text = data.0
            cell.detail?.text = "\(data.1) track\(data.1 == 1 ? "" : "s")"
            cell.artwork1?.image = data.2[0].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork2?.image = data.2[1].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork3?.image = data.2[2].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork4?.image = data.2[3].artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = tableView.cellForRow(at: indexPath) as? DetailTableViewCell, let text = row.title.text else { return }
        selected = text
        performSegue(withIdentifier: "ToGenre", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension GenreLibraryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Set(details.map { $0.0.first! }).count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as? CollectionViewHeader
                else { fatalError("Invalid view type") }
            
            header.title.text = String(Array(Set(details.map { $0.0.first! })).sorted(by: <)[indexPath.section])
            return header
        default:
            assert(false, "Invalid element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = Array(Set(details.map { String($0.0.first!) })).sorted(by: <)[section].first!
        return details.filter({ $0.0.first! == key }).count
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return Array(Set(details.map { String($0.0.first!) })).sorted(by: <)
    }
    
    /// sectionForSectionIndexTitle (for alphabet scrubber)
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return index
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let key = Array(Set(details.map { String($0.0.first!) })).sorted(by: <)[indexPath.section].first!
        let data = details.filter({ $0.0.first! == key })[indexPath.row]
        if data.2.count < 4 {
            let cell: ArtDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "genre", for: indexPath) as! ArtDetailCollectionViewCell
            cell.title.text = data.0
            cell.detail.text = "\(data.1) track\(data.1 == 1 ? "" : "s")"
            cell.artwork?.image = data.2.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        } else {
            let cell: MultiArtDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "genre_multi", for: indexPath) as! MultiArtDetailCollectionViewCell
            cell.title.text = data.0
            cell.detail.text = "\(data.1) track\(data.1 == 1 ? "" : "s")"
            cell.artwork1?.image = data.2[0].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork2?.image = data.2[1].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork3?.image = data.2[2].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork4?.image = data.2[3].artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell, let text = item.title.text else { return }
        selected = text
        performSegue(withIdentifier: "ToGenre", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
