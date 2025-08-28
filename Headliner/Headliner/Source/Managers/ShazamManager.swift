//
//  ShazamManager.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import ShazamKit

protocol ShazamManagerType {
    func getListeningStatus() -> Bool
    func prepare() async
    func startShazam() -> MusicSearchResult?
    func isPossibleShazam() -> Bool?
    func cancel() -> ShazamStatus
}

final class ShazamManager: ShazamManagerType {
    private let shManagedSession = SHManagedSession()
    var isListening: Bool = false
    var status: ShazamStatus = .search
}

extension ShazamManager {
    
    func getListeningStatus() -> Bool {
        return isListening
    }
    
    func prepare() async {
        await shManagedSession.prepare()
    }
    
//    func start() {
//        startShazam()
//    }
    
//    func startShazamForRetry() {
//        startShazam(shouldTriggerNavigation: false)
//    }
    
    
    func isPossibleShazam() -> Bool? {
        guard isListening == false else { return false }
        isListening = true
        
        return true
    }
    
    func startShazam() -> MusicSearchResult? {
        print("ShazamManager startShazam")
        
//        currentItem = nil
//        errorDescription = nil
        status = .loading
        
        var handledResult: MusicSearchResult? = nil
        
//        if shouldTriggerNavigation {
//            container.pathModel.append(.loading)
//            pathModel.append(.loading)
//        }
        
        Task { [weak self] in
            guard let self else { return }
            let result = await self.shManagedSession.result()
            
            let item = await self.handle(result)
            handledResult = MusicSearchResult(
                title: item?.title ?? "",
                artist: item?.artist ?? "",
                artworkURL: item?.artworkURL,
                mediaItem: item,
                showsRetryButton: true
            )
        }
        
        return handledResult
    }
    
//    func retry() {
//        startShazam()
//    }
    
    func cancel() -> ShazamStatus {
        shManagedSession.cancel()
        isListening = false
        status = .search
        
        return .search
    }
    
    /// Shazam 검색 성공 시 결과 return
    private func handle(_ result: SHSession.Result) async -> SHMatchedMediaItem? {
        shManagedSession.cancel()
        isListening = false
        
        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
//                currentItem = item
                status = .completed
                
                return item
                
//                let route = MusicSearchResult(
//                    title: item.title ?? "",
//                    artist: item.artist ?? "",
//                    artworkURL: item.artworkURL,
//                    mediaItem: item,
//                    showsRetryButton: true
//                )
                
//                container.pathModel.append(.result(route))
                //                navigationRoute = .result(route)
            } else {
//                currentItem = nil
                return nil
            }
        case .noMatch:
//            currentItem = nil
            return nil
        case .error(let error, _):
//            errorDescription = error.localizedDescription
//            currentItem = nil
            return nil
        }
    }
    
}
