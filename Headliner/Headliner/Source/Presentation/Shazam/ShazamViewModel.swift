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

struct KaraokeNumbers {
    let tj: String
    let ky: String
}

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
    
    @Published var results: [Song] = []
    @Published var addedSongIDs: Set<String> = []
    
    var container: DIContainer
    var tjMediaService = TJMediaService()
    var kyMediaService = KYMediaService()
    var destination: PathType?
    var errorDescription: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var shazamTask: Task<Void, Never>?
    
    // 캐시: [title-artist: KaraokeNumbers]
    private var karaokeCache: [String: KaraokeNumbers] = [:]
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func requestAuthorization() async -> MusicAuthorization.Status {
        let result = await container.managers.musicManager.requestAuthorization()
        
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
        } else if permissionStatus == .undetermined {
            Task {
                let granted = await container.managers.shazamManager.requestMicrophonePermission()
                guard granted else {
                    await MainActor.run { self.showPermissionAlert = true }
                    return
                }
                await executeShazam()
            }
            return
        }
        Task {
            await executeShazam()
        }
    }
    
    func executeShazam() async {
        guard container.managers.shazamManager.isPossibleShazam() == true else {
            return
        }
        
        shazamTask?.cancel()
        
        container.pathModel.paths.append(.loading)
        
        shazamTask = Task {
            await container.managers.shazamManager.prepare()
            let result = await container.managers.shazamManager.startShazam()
            
            guard !Task.isCancelled else { return }
            
            if let result = result, result.mediaItem != nil {
                self.result = result
                prefetchKaraokeNumbers(title: result.title, artist: result.artist)
                
                let destination = PathType.result(result)
                container.pathModel.pop()
                container.pathModel.append(destination)
            } else {
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
    
    /// SwiftData에서 이미 추가된 노래 ID를 로드
    func loadAddedSongIDs(context: ModelContext) {
        let descriptor = FetchDescriptor<PlaylistMusic>()
        
        do {
            let existing = try context.fetch(descriptor)
            addedSongIDs = Set(existing.map { $0.originalSong.id })
        } catch {
            print("@Log - addedSongIDs 로드 실패: \(error)")
        }
    }
    
    /// 검색 결과에서 노래 추가 (화면 이동 없이)
    @MainActor
    func addSongFromSearch(song: Song, context: ModelContext) async {
        // 이미 추가된 노래인지 확인
        guard !addedSongIDs.contains(song.id) else { return }
        
        let inserted = await addSong(song: song, context: context)
        
        // 실제로 추가된 경우에만 상태 업데이트
        if inserted {
            addedSongIDs.insert(song.id)
        }
    }
    
    private var searchTask: Task<Void, Error>?
    
    private func handleQueryChange(newQuery: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try await Task.sleep(for: .milliseconds(500))
            
            if newQuery.count >= 2 {
                await search(with: newQuery)
            } else {
                results = []
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
    @discardableResult
    func addSong(song: Song, context: ModelContext) async -> Bool {
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
                return false
            }
        } catch {
            print("@Log - \(error)")
            return false
        }

        let key = getCacheKey(title: song.title, artist: song.artistName)
        let cached = karaokeCache[key]
        
        // 1. TJ 번호 처리 (캐시 있으면 사용, 없으면 API 호출)
        let tjNumber: String
        if let cached = cached {
            tjNumber = cached.tj
        } else {
            tjNumber = await fetchTJNumber(title: song.title, artist: song.artistName) ?? "없음"
            // TJ를 가져온 후 즉시 캐시에 저장
            karaokeCache[key] = KaraokeNumbers(tj: tjNumber, ky: "없음")
        }
        
        // 2. 즉시 저장
        let newPlaylistSong = PlaylistMusic(
            originalSong: song,
            tjNumber: tjNumber,
            kyNumber: nil
        )
        context.insert(newPlaylistSong)
        
        // 3. KY 번호 처리 (캐시에 있으면 즉시 설정, 없으면 백그라운드)
        if let cached = cached, cached.ky != "없음" {
            newPlaylistSong.kyNumber = cached.ky
            print("Playlist에 추가됨: \(song.title) - TJ: \(tjNumber), KY: \(cached.ky)")
        } else {
            print("Playlist에 추가됨: \(song.title) - TJ: \(tjNumber), KY: Fetching...")
            
            Task {
                let kyNumber = await fetchKYNumber(title: song.title, artist: song.artistName) ?? "없음"
                
                await MainActor.run {
                    karaokeCache[key] = KaraokeNumbers(tj: tjNumber, ky: kyNumber)
                    newPlaylistSong.kyNumber = kyNumber
                    print("KY Update 완료: \(song.title) - \(kyNumber)")
                }
            }
        }
        
        return true
    }
    
    
    private func getCacheKey(title: String, artist: String) -> String {
        "\(title)-\(artist)"
    }
    
    /// 캐시 확인 후, 없으면 TJ/KY 병렬로 fetch
    private func fetchKaraokeNumbers(title: String, artist: String) async -> KaraokeNumbers {
        let key = getCacheKey(title: title, artist: artist)
        
        // 캐시에 있으면 바로 리턴
        if let cached = karaokeCache[key] {
            return cached
        }
        
        // 병렬로 fetch
        async let tj = fetchTJNumber(title: title, artist: artist)
        async let ky = fetchKYNumber(title: title, artist: artist)
        
        let numbers = KaraokeNumbers(
            tj: await tj ?? "없음",
            ky: await ky ?? "없음"
        )
        
        // 캐시 저장
        karaokeCache[key] = numbers
        
        return numbers
    }
    
    private func fetchTJNumber(title: String, artist: String) async -> String? {
        do {
            return try await tjMediaService.fetchKaraokeNumber(title: title, artist: artist)
        } catch {
            print("TJ 번호 가져오기 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchKYNumber(title: String, artist: String) async -> String? {
        do {
            return try await kyMediaService.fetchKaraokeNumber(title: title, artist: artist)
        } catch {
            print("KY 번호 가져오기 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 미리 가져오기 (백그라운드에서 비동기로)
    private func prefetchKaraokeNumbers(title: String, artist: String) {
        Task {
            await fetchKaraokeNumbers(title: title, artist: artist)
        }
    }
    
    // MARK: - Navigation
    
    func goToPlaylist() {
        container.pathModel.removeAll()
    }
    
    func goToBack() {
        shazamTask?.cancel()
        container.managers.shazamManager.cancel()
        container.pathModel.pop()
    }
}
