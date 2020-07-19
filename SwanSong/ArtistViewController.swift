//
//  ArtistViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 15/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var artistID: MPMediaEntityPersistentID? = nil
    var tracks: [MPMediaItem] = []
    
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "album")
        listView.register(UINib(nibName: "NumberDetailTableCell", bundle: nil), forCellReuseIdentifier: "track")
        
        guard let tracks = MPMediaQuery.artists().collections?.filter({ $0.persistentID == artistID }).first?.items else { return }
        var tmp = [MPMediaEntityPersistentID : [MPMediaItem]]()
        tracks.forEach { track in
            let albumID = track.albumPersistentID
            if tmp[albumID] == nil { tmp[albumID] = [] }
            tmp[albumID]?.append(track)
        }
        groups = tmp.map {
            Group(
                $0.value[0].albumTitle ?? "",
                $0.value.sorted(by: { ($0.discNumber, $0.albumTrackNumber) < ($1.discNumber, $1.albumTrackNumber) })
            )
        }.sorted(by: { $0.name < $1.name })
        self.tracks = groups.flatMap({ $0.items })
        
    }
    
}

extension ArtistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: ArtDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "album", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = groups[indexPath.section].name
            cell.detail?.text = groups[indexPath.section].items.first?.albumArtist ?? ""
            cell.artwork?.image = groups[indexPath.section].items.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell: NumberDetailTableViewCell = listView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! NumberDetailTableViewCell
            cell.title?.text = groups[indexPath.section].items[indexPath.row - 1].title ?? ""
            cell.number.text = "\(groups[indexPath.section].items[indexPath.row - 1].albumTrackNumber)"
            let time = Formatter.string(from: groups[indexPath.section].items[indexPath.row - 1].playbackDuration)
            cell.detail?.text = time
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let skip = groups[0..<indexPath.section].map({ $0.items.count }).reduce(0, +) + indexPath.row
            Player.play(tracks, skipping: skip - 1)
            performSegue(withIdentifier: "ToPlayer", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
