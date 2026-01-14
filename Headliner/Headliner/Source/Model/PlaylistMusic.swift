import Foundation
import MusicKit
import SwiftData

@Model
class PlaylistMusic: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var originalSong: Song
    var tjNumber: String?
    var kyNumber: String?
    
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
