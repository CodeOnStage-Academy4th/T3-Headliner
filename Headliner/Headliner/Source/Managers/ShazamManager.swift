//
//  ShazamManager.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import AVFoundation
import ShazamKit

protocol ShazamManagerType {
    func getMicrophonePermissionStatus() -> AVAudioApplication.recordPermission
    func requestMicrophonePermission() async -> Bool
    func getListeningStatus() -> Bool
    func prepare() async
    func startShazam() async -> MusicSearchResult?
    func isPossibleShazam() -> Bool?
    func cancel() -> ShazamStatus
}

final class ShazamManager: ShazamManagerType {
    private let shManagedSession = SHManagedSession()
    var isListening: Bool = false
    var status: ShazamStatus = .search
}

extension ShazamManager {
    func getMicrophonePermissionStatus() -> AVAudioApplication.recordPermission {
        return AVAudioApplication.shared.recordPermission
    }
    
    func requestMicrophonePermission() async -> Bool {
        return await AVAudioApplication.requestRecordPermission()
    }
    
    func getListeningStatus() -> Bool {
        return isListening
    }
    
    func prepare() async {
        await shManagedSession.prepare()
    }
    
    func isPossibleShazam() -> Bool? {
        guard isListening == false else { return false }
        isListening = true
        
        return true
    }
    
    func startShazam() async -> MusicSearchResult? {
        status = .loading
        
        let result = await shManagedSession.result()
        let matchedItem = await handle(result) // nil 가능
        
        var searchResult: MusicSearchResult
        
        if let matchedItem = matchedItem {
            searchResult = MusicSearchResult(status: .completeShazam, title: matchedItem.title ?? "", artist: matchedItem.artist ?? "", artworkURL: matchedItem.artworkURL, mediaItem: matchedItem)

        } else {
            searchResult = MusicSearchResult(status: .failure, title: "", artist: "", artworkURL: .init(string: ""), mediaItem: nil)
        }
        
//        let searchResult = MusicSearchResult(
//            result: ., title: matchedItem?.title ?? "결과 없음",
//            artist: matchedItem?.artist ?? "",
//            artworkURL: matchedItem?.artworkURL,
//            mediaItem: matchedItem,
//            showsRetryButton: matchedItem == nil
//        )
//
        return searchResult
    }
    
    func cancel() -> ShazamStatus {
        shManagedSession.cancel()
        isListening = false
        status = .search
        
        return .search
    }
    
    /// Shazam 검색 성공 시 결과 return
    private func handle(_ result: SHSession.Result) async -> SHMatchedMediaItem? {
        isListening = false
        
        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
                status = .completed
                return item
            } else {
                return nil
            }
        case .noMatch:
            print("No match found")
            return nil
        case .error(let error, _):
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
