//
//  GenreViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class GenreViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var genreID: MPMediaEntityPersistentID? = nil
    var collections = [MPMediaItemCollection]()
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "album")
        listView.register(UINib(nibName: "NumberDetailTableCell", bundle: nil), forCellReuseIdentifier: "track")
        
        let query = MPMediaQuery.genres()
        let filter = MPMediaPropertyPredicate(value: genreID, forProperty: MPMediaItemPropertyGenrePersistentID)
        query.addFilterPredicate(filter)
        query.groupingType = .album
        collections = query.collections ?? []
        tracks = query.items ?? []
        
    }
    
}

extension GenreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! ArtDetailTableViewCell
            cell.title.text = collections[indexPath.section].representativeItem?.albumTitle ?? ""
            cell.detail?.text = collections[indexPath.section].representativeItem?.albumArtist ?? ""
            cell.artwork?.image = collections[indexPath.section].representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80))
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell: NumberDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! NumberDetailTableViewCell
            let item = collections[indexPath.section].items[indexPath.row - 1]
            cell.title.text = item.title ?? ""
            cell.number.text = "\(item.albumTrackNumber)"
            cell.detail?.text = Formatter.string(from: item.playbackDuration)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let skip = collections[0..<indexPath.section].map({ $0.count }).reduce(0, +) + indexPath.row - 1
            Player.play(tracks, skipping: skip)
            performSegue(withIdentifier: "ToPlayer", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
