//
//  AlbumViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var trackListView: UITableView!
    var albumID: MPMediaEntityPersistentID? = nil
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackListView.delegate = self
        trackListView.dataSource = self
        trackListView.tableFooterView = UIView()
        
        let albumFilter = MPMediaPropertyPredicate(value: albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
        let filterSet = Set([albumFilter])
        tracks = MPMediaQuery(filterPredicates: filterSet).items ?? []
        
        trackListView.reloadData()
    }
    
}

extension AlbumViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: AlbumTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! AlbumTableViewCell
            cell.albumTitle?.text = tracks.first?.albumTitle ?? ""
            cell.albumArtist?.text = tracks.first?.albumArtist ?? ""
            cell.albumArtwork?.image = tracks.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        case tracks.count + 1:
            let cell: FooterTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        default:
            let cell: SongTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SongTableViewCell
            cell.trackTitle?.text = tracks[indexPath.row - 1].title!
            cell.trackNumber?.text = String(tracks[indexPath.row - 1].albumTrackNumber)
            let time = Formatter.string(from: tracks[indexPath.row - 1].playbackDuration)
            cell.trackDuration?.text = time
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
            trackListView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}