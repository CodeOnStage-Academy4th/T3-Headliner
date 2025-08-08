//
//  ShazamSearchView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import ShazamKit

private struct MediaRoute: Hashable {
    let title: String
    let artist: String
    let artworkURL: URL?
    let mediaItem: SHMediaItem?
}

struct ShazamSearchView: View {
    @StateObject private var viewModel = ShazamViewModel()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 24) {
                shazamButton
                Text("샤잠하려면 탭하세요")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .task {
                await viewModel.prepare()
            }
            .onChange(of: viewModel.currentItem) { _, item in
                if let item {
                    let route = MediaRoute(
                        title: item.title ?? "",
                        artist: item.artist ?? "",
                        artworkURL: item.artworkURL,
                        mediaItem: item
                    )
                    path.append(route)
                }
            }
            .navigationDestination(for: MediaRoute.self) { route in
                if let mediaItem = route.mediaItem {
                    MediaItemView(mediaItem: mediaItem)
                } else {
                    // TODO - 검색결과 찾을 수 없음 뷰로 이동
                    Text("MediaItem을 찾을 수 없습니다")
                }
            }
        }
    }

    private var shazamButton: some View {
        Button(action: {
            if !viewModel.isListening {
                viewModel.start()
            }
        }) {
            Image(systemName: "shazam.logo.fill")
                .resizable()
                .frame(width: 52, height: 52)
                .symbolEffect(.pulse, isActive: viewModel.isListening)
                .foregroundColor(viewModel.isListening ? .orange : .blue)
        }
        .disabled(viewModel.isListening)
    }
}

