//
//  ResultViewModel.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation

@MainActor
@Observable
class ResultViewModel {
    var songResponse: SongResponse?
    var songService = SongService()
}

extension ResultViewModel {
    
    @MainActor
    func searchSongExact(title: String, brand: String, limit: String, page: String) async {
        do {
            let newResponse = try await songService.searchExactSongs(title: title, brand: brand, limit: limit, page: page)
            self.songResponse = newResponse
        } catch {
            Log.network("Result VM - searchSongExact error", error)
        }
    }
}
