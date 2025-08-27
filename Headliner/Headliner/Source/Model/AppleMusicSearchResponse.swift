//
//  AppleMusic.swift
//  Headliner
//
//  Created by Soop on 8/20/25.
//


struct AppleMusicSearchResponse: Codable {
    let results: SearchResults
}

struct SearchResults: Codable {
    let songs: SongData?
}

struct SongData: Codable {
    let data: [AppleMusicSong]
}

struct AppleMusicSong: Codable {
    let id: String
    let type: String
    let attributes: SongAttributes
}

struct SongAttributes: Codable {
    let name: String
    let artistName: String
    let albumName: String?
    let artwork: Artwork?
    let previews: [Preview]?
    
    struct Artwork: Codable {
        let url: String
        let width: Int?
        let height: Int?
    }
    struct Preview: Codable {
        let url: String
    }
}
