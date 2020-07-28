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
    var library = [MPMediaPlaylist]()
    var selected = -1
    var playlistFolderID: MPMediaEntityPersistentID? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised, then load library
        checkAuthorisation(self) { self.librarySetup() }
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
    }
    
    /// Load playlists from library
    func librarySetup() {
        let query = MPMediaQuery.playlists()
        if let playlistFolderID = playlistFolderID {
            let filter = MPMediaPropertyPredicate(
                value: playlistFolderID,
                forProperty: MPMediaPlaylistPropertyPersistentID,
                comparisonType: .equalTo
            )
            query.addFilterPredicate(filter)
            library = (query.collections?.first as! MPMediaPlaylist).folderItems
        } else {
            library = (query.collections ?? []) as! [MPMediaPlaylist]
        }
        let sublists = library.filter({ $0.isAFolder }).flatMap({ $0.folderItems })
        library.removeAll { sublists.contains($0) }
        
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
        
        let title = (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        let detail: String
        if playlist.isAFolder {
            detail = "\(playlist.folderItems.count) playlist\(playlist.folderItems.count == 1 ? "" : "s")"
        } else {
            detail = "\(playlist.count) track\(playlist.count == 1 ? "" : "s")"
        }
        
        if art.count == 4 {
            let cell = listView.dequeueReusableCell(withIdentifier: "playlist_multi", for: indexPath) as! MultiArtDetailTableViewCell
            cell.title?.text = title
            cell.detail.text = detail
            cell.artwork1?.image = art[0].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork2?.image = art[1].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork3?.image = art[2].artwork?.image(at: CGSize(width: 80, height: 80))
            cell.artwork4?.image = art[3].artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        } else {
            let cell = listView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = title
            cell.detail.text = detail
            cell.artwork?.image = playlist.representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if library[indexPath.row].isAFolder {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PlaylistLibrary") as! PlaylistLibraryViewController
            viewController.playlistFolderID = library[indexPath.row].persistentID
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            selected = indexPath.row
            performSegue(withIdentifier: "ToPlaylist", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
