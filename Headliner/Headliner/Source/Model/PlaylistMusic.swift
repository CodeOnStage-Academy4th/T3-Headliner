import Foundation
import MusicKit
import SwiftData

@Model
class PlaylistMusic: Identifiable {
    var id: String = UUID().uuidString
    var originalSong: Song?
    var tjNumber: String?
    var kyNumber: String?

    @Relationship(deleteRule: .cascade, inverse: \MusicPlaylistItem.music)
    var playlistItems: [MusicPlaylistItem]?

    init(
        originalSong: Song,
        tjNumber: String? = nil,
        kyNumber: String? = nil
    ) {
        self.originalSong = originalSong
        self.tjNumber = tjNumber
        self.kyNumber = kyNumber
    }
}
