//
//  SearchViewModel.swift
//
//  Created by Henry on 8/8/25.
//

import Combine
import Foundation
import MusicKit

@Observable
class SearchViewModel {
    var query: String = "" {
        didSet {
            debounceTask?.cancel()
            
            debounceTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    
                    await MainActor.run {
                        if query.count >= 2 {
                            Task {
                                await self.search(with: self.query)
                            }
                        } else {
                            self.results = []
                        }
                    }
                } catch {}
            }
        }
    }
    
    var errorMessage: String?
    var isLoading = false
    var isPlaying = false
    var results: [Music] = []
    var playList: [PlaylistMusic] = []
    
    var karaokeResponse: SongResponse?
    var songService = SongService()

    private let service: MusicServicing
    private var debounceTask: Task<Void, Error>?

    init(service: MusicServicing = MusicManager()) {
        self.service = service

        Task { _ = await service.requestAuthorization() }
    }

    @MainActor
    func search(with term: String) async {
        if term.isEmpty {
            results = []
        } else {
            isLoading = true
            errorMessage = nil

            defer { isLoading = false }

            do {
                let searchResults = try await service.searchSongs(
                    term: term,
                    limit: 25
                )
                results = searchResults.sorted {
                    $0.title.localizedStandardCompare($1.title) == .orderedAscending
                }
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func addMusic(song: Music) async {
//        let titleWithNoSpaces = song.title.replacingOccurrences(of: " ", with: "")
//        let singerWithNoSpaces = song.artistName.replacingOccurrences(of: " ", with: "")
        
//        Task {
//            await getKaraokeNumber(
//                title: titleWithNoSpaces,
//                singer: singerWithNoSpaces,
//                brand: "tj",
//                limit: "10",
//                page: "1"
//            )
//        }
        
        await MainActor.run {
//            let karaokeNum = self.karaokeResponse?.data?.first?.no
            let newPlaylistSong = PlaylistMusic(
                id: song.id,
                originalSong: song,
                karaokeNumber: "000000"
            )
            
            self.playList.append(newPlaylistSong)
            
            print("Playlist에 추가됨: \(newPlaylistSong.originalSong.title) - 노래방 번호: \(newPlaylistSong.karaokeNumber ?? "없음")")
            print("PlayList: \(playList)")
        }
    }
    
    @MainActor
    func getKaraokeNumber(
        title: String,
        singer: String,
        brand: String,
        limit: String,
        page: String
    ) async {
        do {
            let newResponse = try await songService.searchBoth(
                title: title,
                singer: singer,
                brand: brand,
                limit: limit,
                page: page
            )
            self.karaokeResponse = newResponse
        } catch {
            Log.network("Result VM - searchBoth error", error)
        }
    }
}
