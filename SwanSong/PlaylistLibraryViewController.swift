//
//  PlaylistListViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 05/12/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class PlaylistLibraryViewController: SwanSongViewController, UITableViewDelegate {
    
    @IBOutlet weak var listView: UITableView!
    var library = [MPMediaPlaylist]()
    var selected = -1
    var playlistFolderID: MPMediaEntityPersistentID? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// Ensure app is authorised, then load library
        checkAuthorisation(self) { self.librarySetup() }
        
        /// Set list view data
        listView.delegate = self
        listView.dataSource = self
        listView.tableFooterView = UIView()
        listView.register(UINib(nibName: "ArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist")
        listView.register(UINib(nibName: "MultiArtDetailTableCellLarge", bundle: nil), forCellReuseIdentifier: "playlist_multi")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        listView.reloadData()
    }
    
    /// Load playlists from library
    func librarySetup() {
        let query = MPMediaQuery.playlists()
        if let playlistFolderID = playlistFolderID {
            let filter = MPMediaPropertyPredicate(
                value: playlistFolderID,
                forProperty: MPMediaPlaylistPropertyPersistentID
            )
            query.addFilterPredicate(filter)
            library = (query.collections?.first as! MPMediaPlaylist).folderItems
        } else {
            library = (query.collections ?? []) as! [MPMediaPlaylist]
        }
        let sublists = library.filter({ $0.isAFolder }).flatMap({ $0.folderItems })
        library.removeAll { sublists.contains($0) }
        library.removeAll { !$0.isAFolder && isListHidden(with: $0.persistentID) }
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : library.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Add new playlist"
            let button = UIButton(type: .contactAdd)
            button.isUserInteractionEnabled = false
            cell.accessoryView = button
            return cell
        } else {
            let playlist = library[indexPath.row]
            let cell: DetailTableViewCell
            var art = [MPMediaItem]()
            for track in playlist.items {
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
                (cell as! SingleArtDetailTableViewCell).artwork?.image = playlist.representativeItem?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            }
            
            cell.title.text = playlist.title ?? ""
            if playlist.isAFolder {
                let visibleSublists = playlist.folderItems.filter({ !isListHidden(with: $0.persistentID) }).count
                cell.detail.text = "\(visibleSublists) playlist\(visibleSublists == 1 ? "" : "s")"
                (cell as! ArtDetailTableViewCell).isFolderOverlayVisible = true
            } else {
                let count = getList(with: playlist.persistentID)?.tracks.count ?? playlist.count
                cell.detail.text = "\(count) track\(count == 1 ? "" : "s")"
                (cell as! ArtDetailTableViewCell).isFolderOverlayVisible = false
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let controller = MPMediaPickerController(mediaTypes: .music)
            controller.allowsPickingMultipleItems = true
            controller.popoverPresentationController?.sourceView = self.view
            controller.delegate = self
            present(controller, animated: true)
        } else if library[indexPath.row].isAFolder {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PlaylistLibrary") as! PlaylistLibraryViewController
            viewController.playlistFolderID = library[indexPath.row].persistentID
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            selected = indexPath.row
            performSegue(withIdentifier: "ToPlaylist", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !library[indexPath.row].isAFolder && indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.hideList(with: self.library[indexPath.row].persistentID)
            self.library.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
}

extension PlaylistLibraryViewController {
    
    func fetchLists(with id: UInt64) -> [Playlist] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        fetchRequest.predicate = NSPredicate(format: "persistentID = %ld", Int64(bitPattern: id))
        let results: [Playlist]
        do {
            results = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            results = []
            print("Could not fetch. Error: \(error)")
        }
        return results
    }
    
    func save(_ list: MPMediaPlaylist) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)!
        let playlist = NSManagedObject(entity: entity, insertInto: managedContext)
        playlist.setValue(Int64(bitPattern: list.persistentID), forKey: "persistentID")
        playlist.setValue(list.title ?? "", forKey: "title")
        playlist.setValue(false, forKey: "isHidden")
        playlist.setValue(list.items.map({ Int64(bitPattern: $0.persistentID) }), forKey: "tracks")
    }
    
    func isListHidden(with id: UInt64) -> Bool {
        let results = fetchLists(with: id)
        if results.count > 0, let playlist = results.first {
            return playlist.isHidden
        }
        return false
    }
    
    func hideList(with id: UInt64) {
        let results = fetchLists(with: id)
        if results.count > 0, let playlist = results.first {
            playlist.hide()
        }
    }
    
    func getList(with id: UInt64) -> Playlist? {
        let results = fetchLists(with: id)
        if results.count > 0, let playlist = results.first {
            return playlist
        }
        return nil
    }
    
}

extension PlaylistLibraryViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true) {
            print(mediaItemCollection.items.map { $0.title! })
            self.listView.reloadData()
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
}
