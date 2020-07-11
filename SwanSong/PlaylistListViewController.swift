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
    
    @IBOutlet weak var listView: UITableView!
    var library: [MPMediaItemCollection] = []
    var selected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        library = MPMediaQuery.playlists().collections ?? []
        library.sort { list1, list2 in
            (list1.value(forProperty: MPMediaPlaylistPropertyName) as! String) < (list2.value(forProperty: MPMediaPlaylistPropertyName) as! String)
        }
        
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellMedium", bundle: nil), forCellReuseIdentifier: "playlist")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPlaylist" {
            let destinationViewController = segue.destination as! PlaylistViewController
            let playlistID = library[selected].persistentID
            destinationViewController.playlistID = playlistID
        }
    }

}

extension PlaylistListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.count
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! ArtDetailTableViewCell
        cell.title?.text = (library[indexPath.row].value(forProperty: MPMediaPlaylistPropertyName) as! String)
        cell.detail.text = ""
        cell.artwork?.image = library[indexPath.row].items.first?.artwork?.image(at: CGSize(width: 80, height: 80))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        performSegue(withIdentifier: "ToPlaylist", sender: self)
        listView.deselectRow(at: indexPath, animated: true)
    }
    
}
