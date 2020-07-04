//
//  PlaylistListViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 05/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var playlistListView: UITableView!
    var playlistLibrary: [MPMediaItemCollection] = []
    var selected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        playlistListView.delegate = self
        playlistListView.dataSource = self
        playlistListView.tableFooterView = UIView()
        playlistLibrary = MPMediaQuery.playlists().collections ?? []
        playlistLibrary.sort { list1, list2 in
            (list1.value(forProperty: MPMediaPlaylistPropertyName) as! String) < (list2.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        }
        
        playlistListView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPlaylist" {
            let destinationViewController = segue.destination as! PlaylistViewController
            let playlistID = playlistLibrary[selected].persistentID
            destinationViewController.playlistID = playlistID
        }
    }

}

extension PlaylistListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistLibrary.count
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumTableViewCell = playlistListView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumTableViewCell
        cell.albumTitle?.text = (playlistLibrary[indexPath.row].value(forProperty: MPMediaPlaylistPropertyName) as! String)
        cell.albumArtwork?.image = playlistLibrary[indexPath.row].items.first?.artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        performSegue(withIdentifier: "ToPlaylist", sender: self)
        playlistListView.deselectRow(at: indexPath, animated: true)
    }
    
}
