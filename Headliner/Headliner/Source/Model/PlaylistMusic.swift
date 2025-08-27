import Foundation
import MusicKit
import SwiftData

@Model
class PlaylistMusic: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var originalSong: Song
    var karaokeNumber: String?
    
    init(
        originalSong: Song,
        karaokeNumber: String? = nil
    ) {
        self.originalSong = originalSong
        self.karaokeNumber = karaokeNumber
    }
}
