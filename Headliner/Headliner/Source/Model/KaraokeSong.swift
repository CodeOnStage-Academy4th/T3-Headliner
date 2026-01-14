import Foundation

struct KaraokeSong: CustomStringConvertible {
    let number: String
    let title: String
    let artist: String
    
    var description: String {
        return "KaraokeSong(number: \"\(number)\", title: \"\(title)\", artist: \"\(artist)\")"
    }
}
