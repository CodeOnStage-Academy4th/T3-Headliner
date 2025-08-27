//
//  PlaylistViewModel.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import SwiftUI
import SwiftData

@MainActor
class PlaylistViewModel: ObservableObject {
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension PlaylistViewModel {
    /// 플레이리스트가 비어있는지 확인
//    func isEmptyPlaylist() -> Bool {
//        // container.managers.playlistDataManager.isEmpty()
//    }
    
    /// 플레이리스트 전체 목록 조회
//    func getPlaylist() -> [PlaylistMusic] {
//        // container.managers.playlistDataManager.getPlaylists()
//    }

    func deleteItems(
        at offsets: IndexSet,
        from playlists: [PlaylistMusic]
    ) {
        guard let modelContext = container.modelContext else {
            print("@Log - ModelContext 사용 불가능")
            return
        }
        
        for offset in offsets {
            let playlistItem = playlists[offset]
            modelContext.delete(playlistItem)
        }
    }
}
