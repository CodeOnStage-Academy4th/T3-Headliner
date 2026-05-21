//
//  MusicPlaylist.swift
//  Headliner
//
//  플레이리스트 폴더 모델
//

import Foundation
import SwiftData

@Model
final class MusicPlaylist: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \MusicPlaylistItem.playlist)
    var items: [MusicPlaylistItem]

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
    @Attribute(.unique) var id: String
    @Relationship(deleteRule: .nullify)
    var music: PlaylistMusic?
    var playlist: MusicPlaylist?
    var addedAt: Date

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
