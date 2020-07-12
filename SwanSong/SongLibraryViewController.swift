//
//  SongLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 12/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SongLibraryViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    
    var library: [MPMediaItemCollection] = []
    var groups = [Group]()
    var tracks = [MPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Load songs from library
        library = MPMediaQuery.songs().collections ?? []
        library.forEach { item in
            var firstLetter = String(item.items[0].title!.first!.uppercased())
            if !["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"].contains(firstLetter) { firstLetter = "#" }
            if var copy = groups.first(where: { $0.name == firstLetter }) {
                groups.removeAll(where: { $0 == copy })
                copy.items.append(item.items[0])
                groups.append(copy)
            } else {
                groups.append(Group(firstLetter, [item.items[0]]))
            }
        }
        groups.sort(by: <)
        if groups[0].name == "#" {
            groups.append(groups.remove(at: 0))
        }
        tracks = groups.flatMap({ $0.items })
        
        /// Set list view data
        listView.dataSource = self
        listView.delegate = self
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
    }
    
}

extension SongLibraryViewController: UITableViewDataSource {
    
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
        let track = groups[indexPath.section].items[indexPath.row]
        let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! ArtDetailTableViewCell
        cell.title?.text = track.title ?? ""
        let time = Formatter.string(from: track.playbackDuration)
        cell.detail?.text = "\(time ?? "--:--") - \(track.albumArtist ?? "")"
        cell.artwork?.image = track.artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sections = Array(groups[0..<indexPath.section])
        let skips = sections.map({ $0.items.count }).reduce(0, +) + indexPath.row
        Player.play(tracks, skipping: skips)
        performSegue(withIdentifier: "ToPlayer", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
