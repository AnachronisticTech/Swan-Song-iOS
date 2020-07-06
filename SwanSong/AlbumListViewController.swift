//
//  AlbumListViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 03/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var albumListView: UITableView!
    var albumLibrary: [MPMediaItemCollection] = []
    var selected: (Int, Int) = (-1, -1)

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
        
        albumListView.delegate = self
        albumListView.dataSource = self
        albumListView.tableFooterView = UIView()
        albumLibrary = MPMediaQuery.albums().collections ?? []
        
        albumListView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAlbum" {
            let destinationViewController = segue.destination as! AlbumViewController
            let albumID = albumGroups[selected.0].albums[selected.1].albumPersistentID
            destinationViewController.albumID = albumID
        }
    }

    @IBAction func changeView(_ sender: Any) {
        print("hi")
    }
}

extension AlbumListViewController: UITableViewDataSource {

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
        cell.albumTitle?.text = albumGroups[indexPath.section].albums[indexPath.row].albumTitle!
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
