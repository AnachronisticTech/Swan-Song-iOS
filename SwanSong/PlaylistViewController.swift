//
//  PlaylistViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var playlistID: MPMediaEntityPersistentID? = nil
    var playlistTitle: String = ""
    var tracks: [MPMediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        
        let query = MPMediaQuery.playlists()
        let filter = MPMediaPropertyPredicate(value: playlistID, forProperty: MPMediaPlaylistPropertyPersistentID)
        query.addFilterPredicate(filter)
        playlistTitle = (query.collections?.first?.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        tracks = query.items ?? []
        
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
            let cell: DetailTableViewCell
            var art = [MPMediaItem]()
            for track in tracks {
                if !art.contains(where: { $0.albumPersistentID == track.albumPersistentID }) {
                    art.append(track)
                }
                if art.count >= 4 { break }
            }
            
            if art.count == 4 {
                cell = tableView.dequeueReusableCell(withIdentifier: "playlist_multi", for: indexPath) as! MultiArtDetailTableViewCell
                (cell as! MultiArtDetailTableViewCell).artwork1?.image = art[0].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork2?.image = art[1].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork3?.image = art[2].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork4?.image = art[3].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! SingleArtDetailTableViewCell
                (cell as! SingleArtDetailTableViewCell).artwork?.image = tracks.first?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            }
            
            cell.title?.text = playlistTitle
            cell.detail.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s")"
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            cell.selectionStyle = .none
            return cell
            
        case tracks.count + 1:
            let cell = listView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            cell.isUserInteractionEnabled = false
            return cell
            
        default:
            let cell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SingleArtDetailTableViewCell
            let track = tracks[indexPath.row - 1]
            cell.title?.text = track.title ?? ""
            cell.artwork?.image = track.artwork?.image(at: CGSize(width: 50, height: 50)) ?? UIImage(named: "blank_artwork")
            cell.detail?.text = Formatter.string(from: track.playbackDuration)
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
