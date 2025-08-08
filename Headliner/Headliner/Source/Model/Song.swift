//
//  Song.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation

struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
}
