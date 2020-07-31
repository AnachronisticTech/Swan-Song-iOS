//
//  PlaylistViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 04/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class PlaylistViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var playlistID: MPMediaEntityPersistentID? = nil
    var playlistTitle: String = ""
    var tracks: [MPMediaItem] = [] {
        didSet { saveListToCoreData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()

        checkForStoredList {
            let query = MPMediaQuery.playlists()
            let filter = MPMediaPropertyPredicate(value: self.playlistID, forProperty: MPMediaPlaylistPropertyPersistentID)
            query.addFilterPredicate(filter)
            self.playlistTitle = (query.collections?.first as? MPMediaPlaylist)?.title ?? ""
            self.tracks = query.items ?? []
        }
        
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
        listView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
        listView.register(UINib(nibName: "FooterTableCell", bundle: nil), forCellReuseIdentifier: "footer")
    }
    
    func checkForStoredList(else run: (() -> Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "persistentID = %ld", Int64(bitPattern: playlistID!))
        let results: [Playlist]
        do {
            results = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            results = []
            print("Could not fetch. Error: \(error)")
        }

        if results.count > 0, let playlist = results.first {
            playlistTitle = playlist.title
            var tmp = [MPMediaItem]()
            for track in playlist.tracks {
                let query = MPMediaQuery.songs()
                let filter = MPMediaPropertyPredicate(value: UInt64(bitPattern: track), forProperty: MPMediaItemPropertyPersistentID)
                query.addFilterPredicate(filter)
                tmp.append(contentsOf: query.items ?? [])
            }
            tracks = tmp
        } else if let run = run {
            run()
        }
    }
    
    func saveListToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "persistentID = %ld", Int64(bitPattern: playlistID!))

        do {
            let objects = try managedContext.fetch(fetchRequest)
            if objects.count >= 1, let object = objects.first {
                object.setValue(tracks.map({ Int64(bitPattern: $0.persistentID) }), forKey: "tracks")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)!
                let playlist = NSManagedObject(entity: entity, insertInto: managedContext)
                playlist.setValue(Int64(bitPattern: playlistID!), forKey: "persistentID")
                playlist.setValue(playlistTitle, forKey: "title")
                playlist.setValue(tracks.map({ Int64(bitPattern: $0.persistentID) }), forKey: "tracks")
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update and save. \(error)")
        }
    }

    func deleteAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.execute(batchDelete)
            print("All records deleted")
        } catch let error as NSError {
            print("Could not delete. \(error)")
        }
    }
    
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: ArtDetailTableViewCell
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
            cell.showsEditControl = true
            cell.setEditAction {
                tableView.setEditing(!tableView.isEditing, animated: true)
                cell.editButton.setTitle(tableView.isEditing ? "Done" : "Edit", for: .normal)
            }
            return cell
            
        case tracks.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SingleArtDetailTableViewCell
            let track = tracks[indexPath.row - 1]
            cell.title?.text = track.title ?? ""
            cell.artwork?.image = track.artwork?.image(at: CGSize(width: 50, height: 50)) ?? UIImage(named: "blank_artwork")
            cell.detail?.text = Formatter.string(from: track.playbackDuration)
            cell.showsReorderControl = true
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
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEditing {
            return !(indexPath.row == 0 || indexPath.row == tracks.count + 1)
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !(indexPath.row == 0 || indexPath.row == tracks.count + 1)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let track = tracks[sourceIndexPath.row - 1]
        var tmp = tracks
        tmp.remove(at: sourceIndexPath.row - 1)
        tmp.insert(track, at: destinationIndexPath.row - 1)
        tracks = tmp
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        switch proposedDestinationIndexPath.row {
            case 0: return IndexPath(row: 1, section: proposedDestinationIndexPath.section)
            case tracks.count + 1: return IndexPath(row: tracks.count, section: proposedDestinationIndexPath.section)
            default: return proposedDestinationIndexPath
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Remove") { _, _, _ in
            self.tracks.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
}
