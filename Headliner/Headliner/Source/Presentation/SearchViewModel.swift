//
//  SearchViewModel.swift
//  ex_MusicKit
//
//  Created by Henry on 8/8/25.
//

import Foundation
import MusicKit

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isPlaying = false
    @Published var results: [Music] = []
    
    private let service: MusicServicing
    
    init(service: MusicServicing = MusicManager()) {
        self.service = service
        Task { _ = await service.requestAuthorization() }
    }
    
    
    @MainActor
    func searchMusic() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        
        do {
            results = try await service.searchSongs(term: term, limit: 10)
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
    }
}
