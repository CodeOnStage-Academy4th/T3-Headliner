//
//  SearchView.swift
//  Headliner
//
//  Created by Rama on 8/8/25.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

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
                SongListView(viewModel: viewModel, songs: viewModel.results)
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
    var viewModel: SearchViewModel
    
    let songs: [Music]
    var body: some View {
        List(songs) { song in
            SongRowView(viewModel: viewModel, song: song)
        }
        .listStyle(.plain)
    }
}

struct SongRowView: View {
    var viewModel: SearchViewModel
    
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
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title).font(.headline).lineLimit(1)
                    Text(song.artistName).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.addMusic(song: song)
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
            
            Spacer()
        }
    }
}
