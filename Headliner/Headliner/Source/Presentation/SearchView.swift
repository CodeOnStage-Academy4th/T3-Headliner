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
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else {
                List(viewModel.results) { song in
                    SongRowView(song: song)
                }
                .listStyle(.plain)
            }
        }
        .safeAreaInset(edge: .top) {
            SearchBarView(text: $viewModel.query)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("검색할 노래를 입력하세요...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
        }
        .padding(.horizontal, 10)
    }
}

struct SongListView: View {
    let songs: [Music]
    var body: some View {
        List(songs) { song in
            SongRowView(song: song)
        }
        .listStyle(.plain)
    }
}

struct SongRowView: View {
    let song: Music
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Color.gray.opacity(0.2)
                case .empty: ProgressView()
                @unknown default: Color.gray.opacity(0.2)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title).font(.headline).lineLimit(1)
                Text(song.artistName).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                if song.previewURL != nil {
                    Text("미리듣기 가능").font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
}
