//
//  SearchViewModel.swift
//
//  Created by Henry on 8/8/25.
//

import Foundation
import MusicKit
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isPlaying = false
    @Published var results: [Music] = []

    private var cancellables = Set<AnyCancellable>()
    private let service: MusicServicing

    init(service: MusicServicing = MusicManager()) {
        self.service = service
        bindSearchTerm()

        Task { _ = await service.requestAuthorization() }
    }

    private func bindSearchTerm() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in

                if term.count >= 2 {
                    Task {
                        await self?.search(with: term)
                    }
                } else {
                    self?.results = []
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func search(with term: String) async {

        if term.isEmpty {
            results = []
        } else {
            isLoading = true
            errorMessage = nil

            defer { isLoading = false }

            do {
                let searchResults = try await service.searchSongs(term: term, limit: 10)
                results = searchResults.sorted {
                    $0.title.localizedStandardCompare($1.title) == .orderedAscending
                }
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }
        }
    }
}