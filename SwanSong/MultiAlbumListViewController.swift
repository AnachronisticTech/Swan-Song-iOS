//
//  MultiAlbumListViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 21/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class MultiAlbumListViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var query: MPMediaQuery? = nil
    var persistentID: MPMediaEntityPersistentID? = nil
    var filterProperty: String? = nil
    var collections = [MPMediaItemCollection]()
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "album")
        listView.register(UINib(nibName: "NumberDetailTableCell", bundle: nil), forCellReuseIdentifier: "track")
        
        let filterID = MPMediaPropertyPredicate(
            value: persistentID,
            forProperty: filterProperty!
        )
        query!.addFilterPredicate(filterID)
        query!.groupingType = .album
        collections = query!.collections ?? []
        tracks = query!.items ?? []
        
    }
    
}

extension MultiAlbumListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! SingleArtDetailTableViewCell
            cell.title.text = collections[indexPath.section].representativeItem?.albumTitle ?? ""
            cell.detail?.text = collections[indexPath.section].representativeItem?.albumArtist ?? ""
            cell.artwork?.image = collections[indexPath.section].representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! NumberDetailTableViewCell
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
