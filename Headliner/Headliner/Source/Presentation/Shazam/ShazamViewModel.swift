//
//  ShazamViewModel.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import Combine
import Foundation
import MusicKit
import ShazamKit
import SwiftData

@MainActor
final class ShazamViewModel: ObservableObject {
    @Published var currentItem: SHMediaItem?
    @Published var showPermissionAlert: Bool = false
    @Published var result: MusicSearchResult?
    @Published var query: String = "" {
        didSet {
            guard !query.isEmpty else { return }
            handleQueryChange(newQuery: query)
        }
    }
    
    @Published var karaokeNumberCache: [String: String] = [:]
    @Published var results: [Song] = []
    
    var container: DIContainer
    var tjMediaService = TJMediaService() /// 곡번호
    var destination: PathType?
    var errorDescription: String?

    private var cancellables = Set<AnyCancellable>()
    private var shazamTask: Task<Void, Never>?

    init(container: DIContainer) {
        self.container = container
    }
    
    func requestAuthorization() async -> MusicAuthorization.Status {
        let result = await container.managers.musicManager.requestAuthorization()
        
        // TODO: 권한에 따른 화면 처리
        switch result {
        case .notDetermined:
            print("not determined")
        case .denied:
            print("denied")
        case .restricted:
            print("restricted")
        case .authorized:
            print("authorized")
        }
        
        return result
    }
    
    func isListening() -> Bool {
        container.managers.shazamManager.getListeningStatus()
    }
    
    func start() {
        let permissionStatus = container.managers.shazamManager.getMicrophonePermissionStatus()
        
        if permissionStatus == .denied {
            showPermissionAlert = true
            return
        }
        
        guard container.managers.shazamManager.isPossibleShazam() == true else {
            return
        }
        
        // 이전 Task가 있다면 취소
        shazamTask?.cancel()
        
        container.pathModel.paths.append(.loading)
        
        shazamTask = Task {
            let result = await container.managers.shazamManager.startShazam()
            
            guard !Task.isCancelled else { return }
            
            if let result = result, result.mediaItem != nil {
                self.result = result
                prefetchKaraokeNumber(title: result.title, artist: result.artist)
                
                let destination = PathType.result(result)
                container.pathModel.pop()
                container.pathModel.append(destination)
            } else {
                // 노래를 찾지 못했을 경우
                let errorResult = MusicSearchResult(
                    status: .failure,
                    title: "결과 없음",
                    artist: "일치하는 컨텐츠를 찾을 수 없습니다.",
                    artworkURL: nil,
                    mediaItem: nil
                )
                self.result = errorResult
                let destination = PathType.result(errorResult)
                container.pathModel.pop()
                container.pathModel.append(destination)
            }
        }
    }
    
    func retry() {
        container.pathModel.pop()
        start()
    }
    
    func handleMusicSelection(song: Song) {
        container.managers.shazamManager.cancel()

        prefetchKaraokeNumber(title: song.title, artist: song.artistName)

        let properties: [SHMediaItemProperty: Any] = [
            .title: song.title,
            .artist: song.artistName,
            .artworkURL: song.artworkURL as Any
        ]
        let mediaItem = SHMediaItem(properties: properties)
        
        let item = MusicSearchResult(
            status: .complete,
            title: song.title,
            artist: song.artistName,
            artworkURL: song.artworkURL,
            mediaItem: mediaItem
        )
        destination = .result(item)
        container.pathModel.append(.result(item))
    }
    
    private var searchTask: Task<Void, Error>?
    
    private func handleQueryChange(newQuery: String) {
        // 이전 검색 취소
        searchTask?.cancel()
        
        // 새로운 검색 예약
        searchTask = Task {
            try await Task.sleep(for: .milliseconds(500))
            
            if newQuery.count >= 2 {
                await search(with: newQuery)
            } else {
                results = [] // 검색어가 짧으면 결과 초기화
            }
        }
    }
    
    @MainActor
    func search(with term: String) async {
        if term.isEmpty {
            results = []
        } else {
            do {
                let searchResults = try await container.managers.musicManager.searchSongs(
                    term: term,
                    limit: 25
                )
                results = searchResults
            } catch {}
        }
    }
    
    @MainActor
    func addSong(song: Song, context: ModelContext) async {
        let songTitle = song.title
        let songArtist = song.artistName
        let descriptor = FetchDescriptor<PlaylistMusic>(
            predicate: #Predicate {
                $0.originalSong.title == songTitle && $0.originalSong.artistName == songArtist
            }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            guard existing.isEmpty else {
                print("@Log - 노래가 플레이리스트에 이미 존재")
                return
            }
        } catch {
            print("@Log - \(error)")
            return
        }

        let fetchedKaraokeNumber: String?
        if let cached = getCachedKaraokeNumber(title: song.title, artist: song.artistName) {
            fetchedKaraokeNumber = cached
        } else {
            fetchedKaraokeNumber = await getKaraokeNumber(title: song.title, singer: song.artistName)
        }
        
        let newPlaylistSong = PlaylistMusic(
            originalSong: song,
            karaokeNumber: fetchedKaraokeNumber ?? "없음"
        )
        
        context.insert(newPlaylistSong)
        
        print("Playlist에 추가됨: \(newPlaylistSong.originalSong.title) - 노래방 번호: \(newPlaylistSong.karaokeNumber ?? "없음")")
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

    private func getCacheKey(title: String, artist: String) -> String {
        return "\(title)-\(artist)"
    }

    func getCachedKaraokeNumber(title: String, artist: String) -> String? {
        let key = getCacheKey(title: title, artist: artist)
        return karaokeNumberCache[key]
    }

    private func prefetchKaraokeNumber(title: String, artist: String) {
        let key = getCacheKey(title: title, artist: artist)

        guard karaokeNumberCache[key] == nil else { return }

        Task {
            if let number = await getKaraokeNumber(title: title, singer: artist) {
                await MainActor.run {
                    karaokeNumberCache[key] = number
                }
            }
        }
    }
    
    func goToPlaylist() {
        container.pathModel.removeAll()
    }
    
    func goToBack() {
        shazamTask?.cancel()
        container.managers.shazamManager.cancel()
        container.pathModel.pop()
    }
}
