//
//  SongResponse.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation

// MARK: - SongResponse
struct SongResponse: Codable {
    let total: Total?
    let page: Int?
    let offset: Int?
    let limit: Int?
    let data: [SongDatum]?
}

// MARK: - Datum
struct SongDatum: Codable, Identifiable {
    let id = UUID().uuidString
    let brand: Brand?
    let no: String?
    let title: String?
    let singer: String?
    let composer: String?
    let lyricist: String?
    let release: String?
}

enum Brand: String, Codable {
    case kumyoung = "kumyoung"
    case tj = "tj"
}

// MARK: - Total
struct Total: Codable {
    let row: Int?
    let page: Int?
}
