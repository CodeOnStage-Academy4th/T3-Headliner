//
//  ShazamViewModel.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import Foundation
import ShazamKit
import Combine

enum Status {
    case search
    case loading
    case completed
}

@MainActor
final class ShazamViewModel: ObservableObject {
    @Published var isListening: Bool = false
    @Published var currentItem: SHMediaItem?
    @Published var errorDescription: String?
    @Published var status: Status = .search
    @Published var navigationRoute: PathType?
    
    @Published var query: String = ""
    @Published var results: [Music] = []
    @Published private(set) var playList: [PlaylistMusic] = []
    private var playListIDs = Set<String>()
    
    var title: String { currentItem?.title ?? "" }
    var artist: String { currentItem?.artist ?? "" }
    var artworkURL: URL? { currentItem?.artworkURL }
    
    var tjMediaService = TJMediaService()
    
    private var cancellables = Set<AnyCancellable>()
    private let service: MusicServicing
    private let managedSession = SHManagedSession()
    private let library = SHLibrary.default
    
    init(service: MusicServicing = MusicManager()) {
        self.service = service
        bindSearchTerm()
        Task { _ = await service.requestAuthorization() }
    }
    
    func prepare() async {
        await managedSession.prepare()
    }
    
    func start() {
        startShazam(shouldTriggerNavigation: true)
    }

    func startShazamForRetry() {
        startShazam(shouldTriggerNavigation: false)
    }

    private func startShazam(shouldTriggerNavigation: Bool) {
        guard isListening == false else { return }
        isListening = true
        currentItem = nil
        errorDescription = nil
        status = .loading
        
        if shouldTriggerNavigation {
            navigationRoute = .loading
        }
        
        Task { [weak self] in
            guard let self else { return }
            let result = await self.managedSession.result()
            await self.handle(result)
        }
    }
    
    func retry() {
        startShazamForRetry()
    }
    
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
                
                let route = MediaRoute(
                    title: item.title ?? "",
                    artist: item.artist ?? "",
                    artworkURL: item.artworkURL,
                    mediaItem: item,
                    showsRetryButton: true
                )
                navigationRoute = .result(route)
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
    
    func handleMusicSelection(song: Music) {
        let properties: [SHMediaItemProperty: Any] = [
            .title: song.title,
            .artist: song.artistName,
            .artworkURL: song.artworkURL as Any
        ]
        let mediaItem = SHMediaItem(properties: properties)
        
        let route = MediaRoute(
            title: song.title,
            artist: song.artistName,
            artworkURL: song.artworkURL,
            mediaItem: mediaItem,
            showsRetryButton: false
        )
        navigationRoute = .result(route)
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
                            await self.search(with: self.query)
                        }
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
                results = searchResults
            } catch {
            }
        }
    }
    
    @MainActor
    func addMusic(song: Music) async {
        guard playListIDs.insert(song.id).inserted else { return }
        
        let fetchedKaraokeNumber = await getKaraokeNumber(
            title: song.title,
            singer: song.artistName
        )
        
        let newPlaylistSong = PlaylistMusic(
            id: song.id,
            originalSong: song,
            karaokeNumber: fetchedKaraokeNumber ?? "없음"
        )
        
        playList.append(newPlaylistSong)
        
        print("Playlist에 추가됨: \(newPlaylistSong.originalSong.title) - 노래방 번호: \(newPlaylistSong.karaokeNumber ?? "없음")")
        print("PlayList: \(playList)")
    }
    
    @MainActor
    func getKaraokeNumber(title: String, singer: String) async -> String? {
        do {
            return try await tjMediaService.fetchKaraokeNumber(title: title, artist: singer)
        } catch {
            print("노래방 번호 가져오기 실패: \(error.localizedDescription)")
            return nil
        }
    }
}
