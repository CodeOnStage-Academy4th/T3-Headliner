//
//  ShazamViewModel.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import Foundation
import ShazamKit
import Combine

@MainActor
final class ShazamViewModel: ObservableObject {
    @Published var isListening: Bool = false
    @Published var currentItem: SHMediaItem?
    @Published var errorDescription: String?
    @Published var status: Status = .search
    
    @Published var query: String = ""
    @Published var results: [Music] = []
    @Published var playList: [PlaylistMusic] = []

    var title: String { currentItem?.title ?? "" }
    var artist: String { currentItem?.artist ?? "" }
    var artworkURL: URL? { currentItem?.artworkURL }
    
    var karaokeResponse: SongResponse?
    var songService = SongService()
    
    private var cancellables = Set<AnyCancellable>()
    private let service: MusicServicing

    private let managedSession = SHManagedSession()
    private let library = SHLibrary.default

    init(service: MusicServicing = MusicManager()) {
        self.service = service
        bindSearchTerm()
    enum Status {
        case search
        case loading
        case completed
    }

        Task { _ = await service.requestAuthorization() }
    }

    func prepare() async {
        await managedSession.prepare()
    }

    func start() {
        guard isListening == false else { return }
        isListening = true
        currentItem = nil
        errorDescription = nil
        self.status = .loading

        Task { [weak self] in
            guard let self else { return }
            let result = await self.managedSession.result()
            await self.handle(result)
        }
    }

    func retry() { start() }

    func cancel() {
        managedSession.cancel()
        isListening = false
        status = .search
    }

    private func handle(_ result: SHSession.Result) async {
        managedSession.cancel()
        isListening = false

        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
                currentItem = item
                    status = .completed
            } else {
                currentItem = nil
            }
        case .noMatch:
            currentItem = nil
        case .error(let error, _):
            errorDescription = error.localizedDescription
            currentItem = nil
        }
    }
    
    private func bindSearchTerm() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if term.count >= 2 {
                    Task {
                        await self.search(with: term)
                    }
                } else {
                    self.results = []
                }
            }
        }
            .store(in: &cancellables)
    }
    
    @MainActor
    func search(with term: String) async {
        if term.isEmpty {
            results = []
        } else {
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
            }
        }
    }
    
    func addMusic(song: Music) async {
        await MainActor.run {
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
        } catch {}
    }
}
