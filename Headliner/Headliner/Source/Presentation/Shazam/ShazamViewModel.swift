//
//  ShazamViewModel.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import Foundation
import ShazamKit
import Combine
import MusicKit
import SwiftData


@MainActor
//@Observable
final class ShazamViewModel: ObservableObject {
    
    @Published var currentItem: SHMediaItem?
    @Published var result: MusicSearchResult?
    @Published var query: String = "" {
        didSet {
            handleQueryChange(newQuery: query)
        }
    }
    @Published var results: [Song] = []
    
    var container: DIContainer
    var tjMediaService = TJMediaService()                   /// 곡번호
    var destination: PathType?
    var errorDescription: String?

    private var cancellables = Set<AnyCancellable>()

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
        print("ShazamVM - start()")
        container.managers.shazamManager.isPossibleShazam()
        let status = container.managers.shazamManager.getListeningStatus()
        
        switch status {
        case true:
            container.pathModel.paths.append(.loading)
            let result = container.managers.shazamManager.startShazam()
            self.result = result
        case false:
            print("않되")
            return
        }
    }
    
    func retry() {
        start()
        container.pathModel.paths.removeLast()
        container.pathModel.paths.append(.loading)
    }
    
    func handleMusicSelection(song: Song) {
        let properties: [SHMediaItemProperty: Any] = [
            .title: song.title,
            .artist: song.artistName,
            .artworkURL: song.artworkURL as Any
        ]
        let mediaItem = SHMediaItem(properties: properties)
        
        let item = MusicSearchResult(
            title: song.title,
            artist: song.artistName,
            artworkURL: song.artworkURL,
            mediaItem: mediaItem,
            showsRetryButton: false
        )
        self.destination = .result(item)
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
            } catch {
            }
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
        
        let fetchedKaraokeNumber = await getKaraokeNumber(
            title: song.title,
            singer: song.artistName
        )
        
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
    
    func goToPlaylist() {
        container.pathModel.removeAll()
    }
    
    func goToBack() {
        container.pathModel.pop()
    }
}
