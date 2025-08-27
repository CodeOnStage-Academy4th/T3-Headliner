//
//  Path.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import Foundation
import Combine

enum PathType: Hashable, Identifiable {
    case loading
    case result(MusicSearchResult)
    
    var id: Int {
        hashValue
    }
}

class PathModel: ObservableObjectSettable {
    
    var objectWillChange: ObservableObjectPublisher?
    
    var paths: [PathType] = [] {
        didSet {
            objectWillChange?.send()
        }
    }
    
    init(paths: [PathType] = []) {
        self.paths = paths
    }

    
    func append(_ path: PathType) {
        self.paths.append(path)
    }
    
    func pop() {
        
        guard !self.paths.isEmpty else { return }
        self.paths.removeLast()
        print("pop() - paths: \(self.paths)")
    }
    
    func removeAll() {
        self.paths.removeAll()
    }
}
