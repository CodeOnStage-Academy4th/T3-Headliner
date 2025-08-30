//
//  ManagerType.swift
//  Headliner
//
//  Created by Soop on 8/21/25.
//

import Foundation

protocol ManagerType {
    var musicManager: MusicManagerType { get set }
    var shazamManager: ShazamManagerType { get set }
}

class Managers: ManagerType {
    var musicManager: MusicManagerType
    var shazamManager: ShazamManagerType
    
    init() {
        self.musicManager = MusicManager()
        self.shazamManager = ShazamManager()
    }
}

