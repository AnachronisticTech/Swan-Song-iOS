//
//  PlaylistViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var trackListView: UITableView!
    var playlistID: MPMediaEntityPersistentID? = nil
    var playlistTitle: String = ""
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackListView.delegate = self
        trackListView.dataSource = self
        trackListView.tableFooterView = UIView()
        
        guard let playlist = MPMediaQuery.playlists().collections?.filter({ $0.persistentID == playlistID }).first else { return }
        tracks = playlist.items
        playlistTitle = (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        
        trackListView.reloadData()
    }
    
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: ArtDetailTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = playlistTitle
            cell.detail.text = ""
            cell.artwork?.image = tracks.first?.artwork?.image(at: CGSize(width: 80, height: 80))
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
            let cell: ArtDetailTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = tracks[indexPath.row - 1].title!
            cell.artwork?.image = tracks[indexPath.row - 1].artwork?.image(at: CGSize(width: 50, height: 50))
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
            trackListView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
