//
//  PlaylistListViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 05/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistLibraryViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var library = [MPMediaItemCollection]()
    var selected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised
        checkAuthorisation(self, then: self.librarySetup)
        librarySetup()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
    }
    
    func librarySetup() {
        library = (MPMediaQuery.playlists().collections ?? []).sorted { list1, list2 in
        (list1.value(forProperty: MPMediaPlaylistPropertyName) as! String) < (list2.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        }
        
        listView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPlaylist" {
            let destinationViewController = segue.destination as! PlaylistViewController
            let playlistID = library[selected].persistentID
            destinationViewController.playlistID = playlistID
        }
    }

}

extension PlaylistLibraryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.count
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playlist = library[indexPath.row]
        var art = [MPMediaItem]()
        for track in playlist.items {
            if !art.contains(where: { $0.albumPersistentID == track.albumPersistentID }) {
                art.append(track)
            }
            if art.count >= 4 { break }
        }
        if art.count == 4 {
            let cell: MultiArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "playlist_multi", for: indexPath) as! MultiArtDetailTableViewCell
            cell.title?.text = (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String)
            cell.detail.text = "\(playlist.items.count) track\(playlist.items.count == 1 ? "" : "s")"
            cell.artwork1?.image = art[0].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork2?.image = art[1].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork3?.image = art[2].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork4?.image = art[3].artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        } else {
            let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String)
            cell.detail.text = "\(playlist.items.count) track\(playlist.items.count == 1 ? "" : "s")"
            cell.artwork?.image = playlist.items.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        performSegue(withIdentifier: "ToPlaylist", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
