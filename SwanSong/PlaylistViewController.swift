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
    var playlistID: Int64!
    var playlistTitle: String = ""
    var tracks: [MPMediaItem] = [] {
        didSet { saveListToCoreData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.allowsSelectionDuringEditing = true

        checkForStoredList {
            let query = MPMediaQuery.playlists()
            let filterPlaylistID = MPMediaPropertyPredicate(
                value: self.playlistID,
                forProperty: MPMediaPlaylistPropertyPersistentID
            )
            query.addFilterPredicate(filterPlaylistID)
            query.addFilterPredicate(filterLocal)
            self.playlistTitle = (query.collections?.first as? MPMediaPlaylist)?.title ?? ""
            self.tracks = query.items ?? []
        }
        
        listView.reloadData()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
        listView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
        listView.register(UINib(nibName: "FooterTableCell", bundle: nil), forCellReuseIdentifier: "footer")
    }
    
}

extension PlaylistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                if tableView.isEditing {
                    return isListLocal() ? 2 : 3
                } else {
                    return 1
                }
            case 2: return 1
            default: return tracks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
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
                    tableView.beginUpdates()
                    let indexPaths = self.isListLocal() ? [IndexPath(row: 1, section: 0)] : [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]
                    if tableView.isEditing {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    } else {
                        tableView.deleteRows(at: indexPaths, with: .fade)
                    }
                    tableView.endUpdates()
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Add tracks"
                let button = UIButton(type: .contactAdd)
                button.isUserInteractionEnabled = false
                cell.accessoryView = button
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Reset iTunes Playlist"
                let button = UIButton(type: .contactAdd)
                button.isUserInteractionEnabled = false
                cell.accessoryView = button
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! FooterTableViewCell
            cell.footer?.text = "\(tracks.count) track\(tracks.count == 1 ? "" : "s") - \(Int((tracks.map({ $0.playbackDuration }).reduce(0, +) / 60).rounded(.up))) minutes"
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SingleArtDetailTableViewCell
            let track = tracks[indexPath.row]
            cell.title?.text = track.title ?? ""
            cell.artwork?.image = track.artwork?.image(at: CGSize(width: 50, height: 50)) ?? UIImage(named: "blank_artwork")
            cell.detail?.text = Formatter.string(from: track.playbackDuration)
            cell.showsReorderControl = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !tableView.isEditing {
            if indexPath.section == 1 {
                Player.play(tracks, skipping: indexPath.row)
                performSegue(withIdentifier: "ToPlayer", sender: self)
            }
        } else {
            if indexPath == IndexPath(row: 1, section: 0) {
                let controller = MPMediaPickerController(mediaTypes: .music)
                controller.allowsPickingMultipleItems = true
                controller.popoverPresentationController?.sourceView = self.view
                controller.delegate = self
                present(controller, animated: true)
            } else if indexPath == IndexPath(row: 2, section: 0) {
                let alert = UIAlertController(title: "Reset Playlist", message: "This will action will reset the state of this playlist to match iTunes. This action cannot be undone.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                let action = UIAlertAction(title: "Reset", style: .default) { _ in
                    let query = MPMediaQuery.playlists()
                    let filterPlaylistID = MPMediaPropertyPredicate(
                        value: self.playlistID,
                        forProperty: MPMediaPlaylistPropertyPersistentID
                    )
                    query.addFilterPredicate(filterPlaylistID)
                    query.addFilterPredicate(filterLocal)
                    self.tracks = (query.collections?.first as? MPMediaPlaylist)?.items ?? []
                    self.listView.reloadData()
                }
                alert.addAction(action)
                present(alert, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing ? indexPath.section == 1 : false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let track = tracks[sourceIndexPath.row]
        var tmp = tracks
        tmp.remove(at: sourceIndexPath.row)
        tmp.insert(track, at: destinationIndexPath.row)
        tracks = tmp
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 {
            return IndexPath(row: 0, section: 1)
        } else if proposedDestinationIndexPath.section == 2 {
            return IndexPath(row: tracks.count - 1, section: 1)
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Remove") { _, _, _ in
            self.tracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
}

extension PlaylistViewController {
    
    func fetchLists() -> [Playlist]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "persistentID = %ld", playlistID)
        return try? managedContext.fetch(fetchRequest)
    }

    func isListLocal() -> Bool {
        if let playlist = fetchLists()?.first {
            return playlist.isLocalItem
        }
        return false
    }
    
    func checkForStoredList(else run: (() -> Void)?) {
        if let results = fetchLists(), let playlist = results.first {
            playlistTitle = playlist.title
            var tmp = [MPMediaItem]()
            for track in playlist.items {
                let query = MPMediaQuery.songs()
                let filterTrackID = MPMediaPropertyPredicate(
                    value: UInt64(bitPattern: track),
                    forProperty: MPMediaItemPropertyPersistentID
                )
                query.addFilterPredicate(filterTrackID)
                query.addFilterPredicate(filterLocal)
                tmp.append(contentsOf: query.items ?? [])
            }
            tracks = tmp
        } else if let run = run {
            run()
        }
    }
    
    func saveListToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let results = fetchLists(), let playlist = results.first {
            playlist.setValue(tracks.map({ Int64(bitPattern: $0.persistentID) }), forKey: "items")
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)!
            let playlist = NSManagedObject(entity: entity, insertInto: managedContext)
            playlist.setValue(playlistID, forKey: "persistentID")
            playlist.setValue(playlistTitle, forKey: "title")
            playlist.setValue(false, forKey: "isHidden")
            playlist.setValue(tracks.map({ Int64(bitPattern: $0.persistentID) }), forKey: "items")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update and save. \(error)")
        }
    }
    
}

extension PlaylistViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true) {
            self.tracks.append(contentsOf: mediaItemCollection.items)
            self.listView.reloadData()
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
}
