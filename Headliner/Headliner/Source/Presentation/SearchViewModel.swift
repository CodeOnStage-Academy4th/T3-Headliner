//
//  SearchViewModel.swift
//  Headliner
//
//  Created by Rama on 8/8/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var searchResults: [Song] = []

    private var cancellables = Set<AnyCancellable>()
    
    //TODO: Delete Dummy
    private let dummySongs: [Song] = [
        Song(title: "뉴진스", artist: "NewJeans"),
        Song(title: "Hype Boy", artist: "NewJeans"),
        Song(title: "Attention", artist: "NewJeans")
    ]

    init() {
        bindSearchTerm()
    }

    private func bindSearchTerm() {
        $searchTerm
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                if searchTerm.count >= 2 {
                    self?.search(with: searchTerm)
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }

    private func search(with term: String) {
        if term.isEmpty {
            searchResults = []
        } else {
            let filteredResults = dummySongs.filter {
                $0.title.localizedCaseInsensitiveContains(term)
            }
            searchResults = filteredResults.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        }
    }
}
