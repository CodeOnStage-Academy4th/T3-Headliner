//
//  SearchView.swift
//  Headliner
//
//  Created by Rama on 8/8/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField(
                    "검색할 노래 제목을 입력하세요",
                    text: $viewModel.searchTerm
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(viewModel.searchResults) { song in
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("노래 검색")
        }
    }
}
