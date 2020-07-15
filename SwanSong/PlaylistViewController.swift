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
    
    @IBOutlet weak var listView: UITableView!
    var playlistID: MPMediaEntityPersistentID? = nil
    var playlistTitle: String = ""
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        
        guard let playlist = MPMediaQuery.playlists().collections?.filter({ $0.persistentID == playlistID }).first else { return }
        tracks = playlist.items
        playlistTitle = (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
        listView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
        listView.register(UINib(nibName: "FooterTableCell", bundle: nil), forCellReuseIdentifier: "footer")
    }
    
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            var art = [MPMediaItem]()
            for track in tracks {
                if !art.contains(where: { $0.albumPersistentID == track.albumPersistentID }) {
                    art.append(track)
                }
                if art.count >= 4 { break }
            }
            if art.count == 4 {
                let cell: MultiArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "playlist_multi", for: indexPath) as! MultiArtDetailTableViewCell
                cell.title?.text = playlistTitle
                cell.detail.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s")"
                cell.artwork1?.image = art[0].artwork?.image(at: CGSize(width: 80, height: 80))
                cell.artwork2?.image = art[1].artwork?.image(at: CGSize(width: 80, height: 80))
                cell.artwork3?.image = art[2].artwork?.image(at: CGSize(width: 80, height: 80))
                cell.artwork4?.image = art[3].artwork?.image(at: CGSize(width: 80, height: 80))
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! ArtDetailTableViewCell
                cell.title?.text = playlistTitle
                cell.detail.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s")"
                cell.artwork?.image = tracks.first?.artwork?.image(at: CGSize(width: 80, height: 80))
                cell.isUserInteractionEnabled = false
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
                return cell
            }
        case tracks.count + 1:
            let cell: FooterTableViewCell = listView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            cell.isUserInteractionEnabled = false
            return cell
        default:
            let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! ArtDetailTableViewCell
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
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
