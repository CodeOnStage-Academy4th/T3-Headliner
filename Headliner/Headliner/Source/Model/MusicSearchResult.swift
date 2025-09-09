//
//  MusicSearchResult.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//

import ShazamKit

/// 뮤직 검색 결과
struct MusicSearchResult: Hashable, Identifiable {
    let id: String = UUID().uuidString
    let status: SearchStatusType
    let title: String
    let artist: String
    let artworkURL: URL?
    let mediaItem: SHMediaItem?
}
