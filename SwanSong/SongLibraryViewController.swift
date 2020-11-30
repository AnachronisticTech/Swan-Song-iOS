//
//  SongLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 12/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class SongLibraryViewController: UITableViewController {

    var library = [MPMediaItem]()
    var collections = [MPMediaItemCollection]()
    var sections = [MPMediaQuerySection]()

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Ensure app is authorised, then load library
        checkAuthorisation(self) {
            /// Load tracks from library
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(filterLocal)
            self.library = query.items ?? []
            self.collections = query.collections ?? []
            self.sections = query.collectionSections ?? []
            self.tableView.reloadData()
        }

        /// Set list view properties
        tableView.register(UINib(nibName: "ArtDetailTableCellSmall", bundle: nil), forCellReuseIdentifier: "track")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.title }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].range.length
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = sections[indexPath.section].range.lowerBound + indexPath.row
        let track = collections[index].representativeItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! SingleArtDetailTableViewCell
        cell.title?.text = track?.title ?? ""
        let time = Formatter.string(from: track?.playbackDuration ?? 0)
        cell.detail?.text = "\(time ?? "--:--") - \(track?.artist ?? "")"
        cell.artwork?.image = track?.artwork?.image(at: CGSize(width: 80, height: 80)) ?? UIImage(named: "blank_artwork")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = sections[indexPath.section].range.lowerBound + indexPath.row
        Player.play(library, skipping: index)
        performSegue(withIdentifier: "ToPlayer", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
