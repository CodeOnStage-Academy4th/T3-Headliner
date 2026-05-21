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

    func nextDefaultPlaylistTitle(from playlists: [MusicPlaylist]) -> String {
        let usedNumbers = Set(
            playlists.compactMap { playlist -> Int? in
                guard playlist.title.hasPrefix("PlayList #") else { return nil }
                return Int(playlist.title.replacingOccurrences(of: "PlayList #", with: ""))
            }
        )

        var nextNumber = 1
        while usedNumbers.contains(nextNumber) {
            nextNumber += 1
        }

        return "PlayList #\(nextNumber)"
    }

    @discardableResult
    func createPlaylist(
        title: String,
        initialMusic: PlaylistMusic? = nil
    ) -> MusicPlaylist? {
        guard let modelContext = container.modelContext else {
            print("@Log - ModelContext 사용 불가능")
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return nil }

        let playlist = MusicPlaylist(title: trimmedTitle)
        modelContext.insert(playlist)

        if let initialMusic {
            addMusic(initialMusic, to: playlist, shouldSave: false)
        }

        save(modelContext)
        return playlist
    }

    func addMusic(
        _ music: PlaylistMusic,
        to playlists: [MusicPlaylist]
    ) {
        guard let modelContext = container.modelContext else {
            print("@Log - ModelContext 사용 불가능")
            return
        }

        playlists.forEach { playlist in
            addMusic(music, to: playlist, shouldSave: false)
        }
        save(modelContext)
    }

    func addMusic(
        _ music: PlaylistMusic,
        toPlaylistsWithIds ids: Set<String>,
        from playlists: [MusicPlaylist]
    ) {
        let targets = playlists.filter { ids.contains($0.id) }
        addMusic(music, to: targets)
    }

    func isMusic(
        _ music: PlaylistMusic,
        includedIn playlist: MusicPlaylist
    ) -> Bool {
        playlist.items.contains { item in
            item.music?.id == music.id
        }
    }

    private func addMusic(
        _ music: PlaylistMusic,
        to playlist: MusicPlaylist,
        shouldSave: Bool = true
    ) {
        guard !isMusic(music, includedIn: playlist) else { return }
        guard let modelContext = container.modelContext else {
            print("@Log - ModelContext 사용 불가능")
            return
        }

        let item = MusicPlaylistItem(
            music: music,
            playlist: playlist
        )
        playlist.items.append(item)
        modelContext.insert(item)

        if shouldSave {
            save(modelContext)
        }
    }

    private func save(_ modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("@Log - 플레이리스트 저장 실패: \(error)")
        }
    }
}
