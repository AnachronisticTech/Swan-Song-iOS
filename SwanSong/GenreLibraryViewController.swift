//
//  GenreLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class GenreLibraryViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var swapViewButton: UIBarButtonItem!
    var library: [MPMediaItemCollection] = []
    var details = [(String, Int, [MPMediaItem])]()
    var selected: String = ""
    
    private let itemsPerRow = 2
    private let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    var isCollectionViewVisible = false {
        willSet {
            newValue ? view.sendSubviewToBack(listView) : view.bringSubviewToFront(listView)
            UserDefaults.standard.set(newValue, forKey: "genreLibraryIsCollectionViewVisible")
            swapViewButton.image = UIImage(named: newValue ? "list" : "grid")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        /// Load genres from library
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
        
        /// Set list view data
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "genre")
        listView.register(UINib(nibName: "MultiArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "genre_multi")
        
        /// Set collection view data
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        layout?.headerReferenceSize = CGSize(width: 0, height: 28)
        collectionView.reloadData()
        collectionView.register(UINib(nibName: "ArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "genre")
        collectionView.register(UINib(nibName: "MultiArtDetailCollectionCell", bundle: nil), forCellWithReuseIdentifier: "genre_multi")
        collectionView.register(
            UINib(nibName: "CollectionViewHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        
        /// Set view to list or collection based on last selection
        isCollectionViewVisible = UserDefaults.standard.value(forKey: "genreLibraryIsCollectionViewVisible") as? Bool ?? false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGenre" {
            let destinationViewController = segue.destination as! GenreViewController
            guard let genre = library.filter({ $0.items[0].genre == selected }).first else { return }
            destinationViewController.genreID = genre.persistentID
        }
    }
    
    @IBAction func swapView(_ sender: Any) {
        isCollectionViewVisible = !isCollectionViewVisible
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
        listView.deselectRow(at: indexPath, animated: true)
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

extension GenreLibraryViewController: UICollectionViewDelegateFlowLayout {
    
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


