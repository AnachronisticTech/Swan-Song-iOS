//
//  AlbumViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var albumID: MPMediaEntityPersistentID? = nil
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        
        let query = MPMediaQuery.albums()
        let filterAlbumID = MPMediaPropertyPredicate(
            value: albumID,
            forProperty: MPMediaItemPropertyAlbumPersistentID
        )
        query.addFilterPredicate(filterAlbumID)
        query.addFilterPredicate(filterLocal)
        tracks = query.items ?? []
        
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "album")
        listView.register(UINib(nibName: "NumberDetailTableCell", bundle: nil), forCellReuseIdentifier: "track")
        listView.register(UINib(nibName: "FooterTableCell", bundle: nil), forCellReuseIdentifier: "footer")
    }
    
}

extension AlbumViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! SingleArtDetailTableViewCell
            cell.title?.text = tracks.first?.albumTitle ?? ""
            cell.detail?.text = tracks.first?.albumArtist ?? ""
            cell.artwork?.image = tracks.first?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        case tracks.count + 1:
            let cell = listView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        default:
            let cell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! NumberDetailTableViewCell
            cell.title?.text = tracks[indexPath.row - 1].title!
            cell.number?.text = String(tracks[indexPath.row - 1].albumTrackNumber)
            let time = Formatter.string(from: tracks[indexPath.row - 1].playbackDuration)
            cell.detail?.text = time
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: return
        case tracks.count + 1: return
        default:
            Player.play(tracks, skipping: indexPath.row - 1)
            performSegue(withIdentifier: "ToPlayer", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
