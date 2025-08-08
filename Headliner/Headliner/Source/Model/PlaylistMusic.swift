import Foundation
import MusicKit

struct PlaylistMusic: Identifiable {
    let id: Music.ID
    let originalSong: Music
    var karaokeNumber: String?
}
