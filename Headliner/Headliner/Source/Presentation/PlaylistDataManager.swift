//
//  PlaylistDataManager.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import Foundation

protocol PlaylistDataManagerType {
    func addMusic(_ music: PlaylistMusic)
    func deleteMusic()
}

@Observable
final class PlaylistDataManager {
    var playlists: [PlaylistMusic] = []
    var isLoading = false
//    var musicManager = MusicManager()
}

extension PlaylistDataManager: PlaylistDataManagerType {
    func addMusic(_ music: PlaylistMusic) {
        
    }
    
    func deleteMusic() {
        
    }
}
