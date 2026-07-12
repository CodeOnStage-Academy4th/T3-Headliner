//
//  MusicPlaylist.swift
//  Headliner
//
//  플레이리스트 폴더 모델
//

import Foundation
import SwiftData

@Model
final class MusicPlaylist: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \MusicPlaylistItem.playlist)
    var items: [MusicPlaylistItem]?

    init(
        id: String = UUID().uuidString,
        title: String,
        createdAt: Date = .now,
        items: [MusicPlaylistItem] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.items = items
    }
}

@Model
final class MusicPlaylistItem: Identifiable {
    var id: String = UUID().uuidString
    var music: PlaylistMusic?
    var playlist: MusicPlaylist?
    var addedAt: Date = Date.now

    init(
        id: String = UUID().uuidString,
        music: PlaylistMusic?,
        playlist: MusicPlaylist? = nil,
        addedAt: Date = .now
    ) {
        self.id = id
        self.music = music
        self.playlist = playlist
        self.addedAt = addedAt
    }
}
