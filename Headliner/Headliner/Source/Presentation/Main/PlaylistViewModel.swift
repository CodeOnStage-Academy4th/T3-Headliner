//
//  PlaylistViewModel.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import SwiftUI

@Observable
class PlaylistViewModel {
//    var playlistDataManager: PlaylistDataManager
    var container: DIContainer
    
    init(
//        playlistDataManager: PlaylistDataManager,
        container: DIContainer
    ) {
//        self.playlistDataManager = playlistDataManager
        self.container = container
    }
}
