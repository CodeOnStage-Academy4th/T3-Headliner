//
//  MusicManager.swift
//  ex_MusicKit
//
//  Created by Henry on 8/8/25.
//

import Foundation
import MusicKit

protocol MusicServicing {
    func requestAuthorization() async -> MusicAuthorization.Status
    func searchSongs(term: String, limit: Int) async throws -> [Music]
}

final class MusicManager: MusicServicing {

    private let storefront = "kr"
    private let languageHeader = "ko-KR"
    private let developerToken: String = ""

    private struct AppleMusicSearchResponse: Codable {
        let results: SearchResults
    }
    private struct SearchResults: Codable {
        let songs: SongData?
    }
    private struct SongData: Codable {
        let data: [AppleMusicSong]
    }
    private struct AppleMusicSong: Codable {
        let id: String
        let type: String
        let attributes: SongAttributes
    }
    private struct SongAttributes: Codable {
        let name: String
        let artistName: String
        let albumName: String?
        let artwork: Artwork?
        let previews: [Preview]?

        struct Artwork: Codable {
            let url: String
            let width: Int?
            let height: Int?
        }
        struct Preview: Codable {
            let url: String
        }
    }
    func requestAuthorization() async -> MusicAuthorization.Status {
        await MusicAuthorization.request()
    }

    func searchSongs(term: String, limit: Int = 10) async throws -> [Music] {
        // 토큰 유효성 체크
        guard developerToken.isEmpty == false else {
            throw URLError(.userAuthenticationRequired)
        }

        // URL 구성
        let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term
        guard let url = URL(string: "https://api.music.apple.com/v1/catalog/\(storefront)/search?term=\(encodedTerm)&types=songs&limit=\(limit)&l=ko") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        request.setValue(languageHeader, forHTTPHeaderField: "Accept-Language")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) == false {
            #if DEBUG
            if let body = String(data: data, encoding: .utf8) { print("[AppleMusicAPI] Error: \(http.statusCode)\n\(body)") }
            #endif
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(AppleMusicSearchResponse.self, from: data)
        let items = decoded.results.songs?.data ?? []

        let mapped: [Music] = items.compactMap { item in
            let artString = item.attributes.artwork?.url.replacingOccurrences(of: "{w}x{h}", with: "200x200")
            let artworkURL = artString.flatMap { URL(string: $0) }

            let previewURL: URL?
            if let urlString = item.attributes.previews?.first?.url {
                previewURL = URL(string: urlString)
            } else {
                previewURL = nil
            }

            return Music(
                id: item.id,
                title: item.attributes.name,
                artistName: item.attributes.artistName,
                artworkURL: artworkURL,
                previewURL: previewURL
            )
        }

        return Array(mapped.prefix(limit))
    }
}
