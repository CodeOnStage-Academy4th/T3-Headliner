//
//  Song.swift
//  ex_MusicKit
//
//  Created by Henry on 8/8/25.
//

import Foundation
import SwiftData

@Model
class Song: Identifiable, Hashable {
    var id: String
    var title: String
    var artistName: String
    var artworkURL: URL?
    var previewURL: URL? // 미리듣기 URL
    
    init(
        id: String,
        title: String,
        artistName: String,
        artworkURL: URL? = nil,
        previewURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.previewURL = previewURL
    }
}
