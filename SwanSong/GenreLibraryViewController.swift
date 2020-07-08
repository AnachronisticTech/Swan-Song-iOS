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
    var groups = [String : [Group]]()
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
        library.forEach { item in
            let genre = item.items[0].genre ?? "Unknown Genre"
            let initial = String(genre.first!)
            if groups[initial] == nil {
                groups[initial] = []
            }
            groups[initial]?.append(Group(genre, item.items))
        }
        
        /// Set list view data
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.reloadData()
        
        /// Set collection view data
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.reloadData()
        
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
        return groups.values.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups.keys.sorted(by: <)[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = groups.keys.sorted(by: <)[section]
        return groups[key]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(Set(groups.keys)).sorted(by: <)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "genre", for: indexPath) as! ArtDetailTableViewCell
        let key = Array(Set(groups.keys)).sorted(by: <)[indexPath.section]
        let group = groups[key]![indexPath.row]
        cell.title.text = group.name
        cell.detail?.text = "\(group.items.count) songs"
//        cell.artwork?.image = groups[indexPath.section].albums[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selected.0 = indexPath.section
//        selected.1 = indexPath.row
        guard let row = tableView.cellForRow(at: indexPath) as? ArtDetailTableViewCell, let text = row.title.text else { return }
        selected = text
        performSegue(withIdentifier: "ToGenre", sender: self)
        listView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension GenreLibraryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as? CollectionViewHeader
                else { fatalError("Invalid view type") }
            
            header.title.text = groups.keys.sorted(by: <)[indexPath.section]
            return header
        default:
            assert(false, "Invalid element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = groups.keys.sorted(by: <)[section]
        return groups[key]?.count ?? 0
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return Array(Set(groups.keys)).sorted(by: <)
    }
    
    /// sectionForSectionIndexTitle (for alphabet scrubber)
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return index
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ArtDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "genre", for: indexPath) as! ArtDetailCollectionViewCell
        let key = Array(Set(groups.keys)).sorted(by: <)[indexPath.section]
        let group = groups[key]![indexPath.row]
        cell.title.text = group.name
        cell.detail?.text = "\(group.items.count) songs"
//        cell.artwork?.image = groups[indexPath.section].albums[indexPath.row].artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selected.0 = indexPath.section
//        selected.1 = indexPath.row
        guard let item = collectionView.cellForItem(at: indexPath) as? ArtDetailCollectionViewCell, let text = item.title.text else { return }
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


