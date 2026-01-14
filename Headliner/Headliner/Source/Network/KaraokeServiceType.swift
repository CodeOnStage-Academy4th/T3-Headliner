import Foundation

protocol KaraokeServiceType {
    func fetchKaraokeNumber(title: String, artist: String) async throws -> String?
}
