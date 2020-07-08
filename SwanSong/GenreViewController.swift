//
//  GenreViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 08/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class GenreViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var trackListView: UITableView!
    var genreID: MPMediaEntityPersistentID? = nil
    var genre: String = ""
    var tracks: [MPMediaItem] = []
    
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackListView.delegate = self
        trackListView.dataSource = self
        trackListView.tableFooterView = UIView()
        
        guard let genreQuery = MPMediaQuery.genres().collections?.filter({ $0.persistentID == genreID }).first else { return }
        tracks = genreQuery.items
        var tmp = [MPMediaEntityPersistentID : [MPMediaItem]]()
        tracks.forEach { track in
            let albumID = track.albumPersistentID
            if tmp[albumID] == nil {
                tmp[albumID] = []
            }
            tmp[albumID]?.append(track)
        }
        groups = tmp.map {
            Group(
                $0.value[0].albumTitle ?? "",
                $0.value.sorted(by: { ($0.discNumber, $0.albumTrackNumber) < ($1.discNumber ,$1.albumTrackNumber) })
            )
        }.sorted(by: { $0.name < $1.name })
        genre = tracks.first?.genre ?? "Unknown Genre"
        
        trackListView.reloadData()
    }
    
}

extension GenreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: ArtDetailTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "genre", for: indexPath) as! ArtDetailTableViewCell
            cell.title?.text = groups[indexPath.section].name
            cell.detail.text = ""
            cell.artwork?.image = groups[indexPath.section].items.first?.artwork?.image(at: CGSize(width: 80, height: 80))
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
//        case groups[indexPath.section].items.count + 1:
//            let cell: FooterTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
//            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
//            cell.isUserInteractionEnabled = false
//            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
//            return cell
        default:
            let cell: NumberDetailTableViewCell = trackListView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! NumberDetailTableViewCell
            cell.title?.text = groups[indexPath.section].items[indexPath.row - 1].title ?? ""
            cell.number.text = "\(groups[indexPath.section].items[indexPath.row - 1].albumTrackNumber)"
            let time = Formatter.string(from: groups[indexPath.section].items[indexPath.row - 1].playbackDuration)
            cell.detail?.text = time
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: return
        default:
            Player.play(groups[indexPath.section].items, skipping: indexPath.row - 1) // Only plays from selected album
            performSegue(withIdentifier: "ToPlayer", sender: self)
            trackListView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
