//
//  AlbumLibraryViewController.swift
//  SwanSong
//
//  Created by Daniel Marriner on 06/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumLibraryViewConrtoller: SwanSongCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Ensure app is authorised, then load library
        checkAuthorisation(self) {
            /// Load albums from library
            let query = MPMediaQuery.albums()
            query.addFilterPredicate(filterLocal)
            self.collections = query.collections ?? []
            self.sections = query.collectionSections ?? []

            self.collectionView.reloadData()
        }
    }
}
