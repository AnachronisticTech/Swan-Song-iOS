//
//  SongLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 12/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SongLibraryViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!

    /// Load tracks from library
    var library = [MPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised, then load library
        checkAuthorisation(self) { self.librarySetup() }
        
        /// Set list view properties
        listView.dataSource = self
        listView.delegate = self
        listView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
    }
    
    /// Load songs from library
    func librarySetup() {
        let query = MPMediaQuery.songs()
        query.addFilterPredicate(filterLocal)
        library = query.items ?? []
        
        listView.reloadData()
    }
    
}

extension SongLibraryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = library[indexPath.row]
        let cell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SingleArtDetailTableViewCell
        cell.title?.text = track.title ?? ""
        let time = Formatter.string(from: track.playbackDuration)
        cell.detail?.text = "\(time ?? "--:--") - \(track.artist ?? "")"
        cell.artwork?.image = track.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Player.play(library, skipping: indexPath.row)
        performSegue(withIdentifier: "ToPlayer", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
