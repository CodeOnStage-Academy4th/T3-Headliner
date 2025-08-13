//
//  Path.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import Foundation
import ShazamKit

struct MediaRoute: Hashable {
    let title: String
    let artist: String
    let artworkURL: URL?
    let mediaItem: SHMediaItem?
}

enum PathType: Hashable {
    case loading
    case result(MediaRoute)
}

class PathModel: ObservableObject {
    @Published var paths: [PathType]
    
    init(paths: [PathType] = []) {  // 빈 배열로 초기화. 앱 실행시 특정 화면을 보여주고 싶다면 해당 뷰로 초기화할 것.
        self.paths = paths
    }
}
