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


@MainActor
//@Observable
final class ShazamViewModel: ObservableObject {
//    var playlistDataManager: PlaylistDataManager
//    var pathModel: PathModel
    var container: DIContainer
    
    var tjMediaService = TJMediaService()                   /// 곡번호
    var destination: PathType?
    
//    private let musicManager = MusicManager()               /// 애플뮤직
//    private let shazamManager = ShazamManager()
//    private let shManagedSession = SHManagedSession()
    
//    var isListening: Bool = false
    @Published var currentItem: SHMediaItem?
    var errorDescription: String?
    @Published var result: MusicSearchResult?
//    var status: ShazamStatus = .search
//        var navigationRoute: PathType?
    
    //    var query: String = ""
    @Published var query: String = "" {
        didSet {
            handleQueryChange(newQuery: query)
        }
    }
    @Published var results: [Music] = []
//        private(set) var playList: [PlaylistMusic] = []
    private var playListIDs = Set<String>()
    
    //    var title: String { currentItem?.title ?? "" }
    //    var artist: String { currentItem?.artist ?? "" }
    //    var artworkURL: URL? { currentItem?.artworkURL }
    
    
    
    private var cancellables = Set<AnyCancellable>()
    
    
    //    private let library = SHLibrary.default
    
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
    
//    func prepare() async {
//        await shManagedSession.prepare()
//    }
    
//    func start() {
//        startShazam(shouldTriggerNavigation: true)
//    }
//    
//    func startShazamForRetry() {
//        startShazam(shouldTriggerNavigation: false)
//    }
//    
//    private func startShazam(shouldTriggerNavigation: Bool) {
//        guard isListening == false else { return }
//        isListening = true
//        currentItem = nil
//        errorDescription = nil
//        status = .loading
//        
//        
//        if shouldTriggerNavigation {
//            container.pathModel.append(.loading)
////            pathModel.append(.loading)
//        }
//        
//        Task { [weak self] in
//            guard let self else { return }
//            let result = await self.shManagedSession.result()
//            await self.handle(result)
//        }
//    }
//    
//    func retry() {
//        startShazamForRetry()
//    }
//    
//    func cancel() {
//        shManagedSession.cancel()
//        isListening = false
//        status = .search
//    }
//    
//    private func handle(_ result: SHSession.Result) async {
//        shManagedSession.cancel()
//        isListening = false
//        
//        switch result {
//        case .match(let match):
//            if let item = match.mediaItems.first {
//                currentItem = item
//                status = .completed
//                
//                let route = MusicSearchResult(
//                    title: item.title ?? "",
//                    artist: item.artist ?? "",
//                    artworkURL: item.artworkURL,
//                    mediaItem: item,
//                    showsRetryButton: true
//                )
//                
//                container.pathModel.append(.result(route))
//                //                navigationRoute = .result(route)
//            } else {
//                currentItem = nil
//            }
//        case .noMatch:
//            currentItem = nil
//            
//        case .error(let error, _):
//            errorDescription = error.localizedDescription
//            currentItem = nil
//        }
//    }
    
    func handleMusicSelection(song: Music) {
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
        //        navigationRoute = .result(route)
    }
    
    //    private func bindSearchTerm() {
    //        $query
    //            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
    //            .removeDuplicates()
    //            .sink { [weak self] term in
    //                DispatchQueue.main.async {
    //                    guard let self = self else { return }
    //
    //                    if term.count >= 2 {
    //                        Task {
    //                            await self.search(with: self.query)
    //                        }
    //                    }
    //                }
    //            }
    //            .store(in: &cancellables)
    //    }
    
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
        
        container.managers.playlistDataManager.addMusic(newPlaylistSong)
//        container.managers.playlistDataManager.playlists.append(newPlaylistSong)
        
        print("Playlist에 추가됨: \(newPlaylistSong.originalSong.title) - 노래방 번호: \(newPlaylistSong.karaokeNumber ?? "없음")")
//        print("PlayList: \(playlistDataManager.playlists)")
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
