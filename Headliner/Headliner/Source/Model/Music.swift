//
//  Music.swift
//  ex_MusicKit
//
//  Created by Henry on 8/8/25.
//

import Foundation

struct Music: Identifiable, Hashable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: URL?
    let previewURL: URL? // 미리듣기 URL
    let karaokeNumber: String = ""
}
