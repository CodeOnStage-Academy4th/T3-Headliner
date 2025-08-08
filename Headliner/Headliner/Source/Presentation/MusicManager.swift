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
    func warmUpIfAuthorized()
}

final class MusicManager: MusicServicing {
    
    func requestAuthorization() async -> MusicAuthorization.Status {
        await MusicAuthorization.request()
    }

    func searchSongs(term: String, limit: Int = 10) async throws -> [Music] {
        var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
        request.limit = limit

        let response = try await request.response()

        let mapped: [Music] = response.songs.map { song in
            let artworkURL = song.artwork?.url(width: 200, height: 200)
            let previewURL = song.previewAssets?.first?.url
            return Music(
                id: song.id.rawValue,
                title: song.title,
                artistName: song.artistName,
                artworkURL: artworkURL,
                previewURL: previewURL
            )
        }

        return Array(mapped.prefix(limit))
    }

    func warmUpIfAuthorized() {
        Task {
            guard MusicAuthorization.currentStatus == .authorized else { return }
            var req = MusicCatalogSearchRequest(term: "Apple", types: [Song.self])
            req.limit = 1
            _ = try? await req.response()
        }
    }
}
