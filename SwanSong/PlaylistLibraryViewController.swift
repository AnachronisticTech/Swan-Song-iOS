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
    var library = [Playlist]()
    var artlib = [Int64: MPMediaPlaylist]()
    var selected = -1
    var playlistFolderID: Int64? = nil
    var newPlaylistTempName: String?
    
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
        if let playlistFolderID = playlistFolderID {
            library = fetchLists(with: playlistFolderID, ofParent: true)!
        } else {
            library = fetchLists()!
        }
        let sublists = library.filter({ $0.isFolder }).flatMap({ $0.folderItems })
        library.removeAll { sublists.contains($0.persistentID) }
        library.removeAll { !$0.isFolder && isListHidden(with: $0.persistentID) }
        library.sort(by: { $0.isFolder && !$1.isFolder })
        for playlist in library {
            let query = MPMediaQuery.playlists()
            let filter = MPMediaPropertyPredicate(
                value: UInt64(bitPattern: playlist.persistentID),
                forProperty: MPMediaPlaylistPropertyPersistentID
            )
            query.addFilterPredicate(filter)
            if let list = query.collections?.first as? MPMediaPlaylist {
                artlib[playlist.persistentID] = list
            }
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
            if let sysPlaylist = artlib[playlist.persistentID] {
                for item in sysPlaylist.items {
                    if !art.contains(where: { $0.albumPersistentID == item.albumPersistentID }) {
                        art.append(item)
                    }
                    if art.count >= 4 { break }
                }
            } else {
                for track in playlist.items {
                    let query = MPMediaQuery.songs()
                    let filter = MPMediaPropertyPredicate(
                        value: UInt64(track),
                        forProperty: MPMediaItemPropertyPersistentID
                    )
                    query.addFilterPredicate(filter)
                    if let item = query.items?.first, !art.contains(where: { $0.albumPersistentID == item.albumPersistentID }) {
                        art.append(item)
                    }
                    if art.count >= 4 { break }
                }
            }
            
            if art.count == 4 {
                cell = tableView.dequeueReusableCell(withIdentifier: "playlist_multi", for: indexPath) as! MultiArtDetailTableViewCell
                (cell as! MultiArtDetailTableViewCell).artwork1?.image = art[0].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork2?.image = art[1].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork3?.image = art[2].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
                (cell as! MultiArtDetailTableViewCell).artwork4?.image = art[3].artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! SingleArtDetailTableViewCell
                (cell as! SingleArtDetailTableViewCell).artwork?.image = art.first?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
            }
            
            cell.title.text = playlist.title
            if playlist.isFolder {
                let visibleSublists = playlist.folderItems.filter({ !isListHidden(with: $0) }).count
                cell.detail.text = "\(visibleSublists) playlist\(visibleSublists == 1 ? "" : "s")"
                (cell as! ArtDetailTableViewCell).isFolderOverlayVisible = true
            } else {
                let count = playlist.items.count
                cell.detail.text = "\(count) track\(count == 1 ? "" : "s")"
                (cell as! ArtDetailTableViewCell).isFolderOverlayVisible = false
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let alert = UIAlertController(title: "New Playlist", message: "Enter a playlist title", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Title"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            let action = UIAlertAction(title: "Select tracks", style: .default) { _ in
                guard alert.textFields!.first!.text != "" else { return }
                self.newPlaylistTempName = alert.textFields!.first!.text!
                let controller = MPMediaPickerController(mediaTypes: .music)
                controller.allowsPickingMultipleItems = true
                controller.popoverPresentationController?.sourceView = self.view
                controller.delegate = self
                self.present(controller, animated: true)
            }
            action.isEnabled = false
            alert.addAction(action)
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: alert.textFields!.first!,
                queue: .main
            ) { _ in
                var text = alert.textFields!.first!.text ?? ""
                while text.first == " " { text.removeFirst() }
                action.isEnabled = text.count > 0
            }
            present(alert, animated: true)
        } else if library[indexPath.row].isFolder {
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
        return !library[indexPath.row].isFolder && indexPath.section == 1
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
    
    func fetchLists(with id: Int64? = nil, ofParent: Bool = false) -> [Playlist]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        if let id = id {
            fetchRequest.predicate = NSPredicate(format: "p\(ofParent ? "arentP" : "")ersistentID = %ld", id)
        }
        return try? managedContext.fetch(fetchRequest)
    }
    
    func isListHidden(with id: Int64) -> Bool {
        if let results = fetchLists(with: id), let playlist = results.first {
            return playlist.isHidden
        }
        return false
    }
    
    func hideList(with id: Int64) {
        if let results = fetchLists(with: id), let playlist = results.first {
            playlist.hide()
        }
    }
    
    func saveNewList(with items: [MPMediaItem]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        
        guard let listIDs = try? managedContext.fetch(fetchRequest).map({ $0.persistentID }) else { return }
        var id: Int64
        repeat { id = Int64.random(in: Int64.min ..< Int64.max) } while listIDs.contains(id)
        let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)!
        let playlist = NSManagedObject(entity: entity, insertInto: managedContext)
        playlist.setValue(id, forKey: "persistentID")
        playlist.setValue(newPlaylistTempName.consume(), forKey: "title")
        playlist.setValue(false, forKey: "isHidden")
        playlist.setValue(false, forKey: "isFolder")
        playlist.setValue(playlistFolderID, forKey: "parentPersistentID")
        playlist.setValue(items.map({ Int64(bitPattern: $0.persistentID) }), forKey: "items")
        playlist.setValue([], forKey: "folderItems")
        if let results = fetchLists(with: playlistFolderID), let parent = results.first {
            parent.folderItems.append(id)
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update and save. \(error)")
        }
    }
    
}

extension PlaylistLibraryViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true) {
            if mediaItemCollection.items.count == 0 { return }
            self.saveNewList(with: mediaItemCollection.items)
            self.librarySetup()
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
}
