//
//  PlaylistFolderRowView.swift
//  Headliner
//
//  플레이리스트 폴더 Row UI
//

import SwiftUI

struct PlaylistFolderRowView: View {
    private enum RowKind {
        case add
        case playlist
    }

    private let title: String
    private let songCount: Int
    private let artworkURLs: [URL?]
    private let kind: RowKind
    private let onTap: (() -> Void)?

    init(onTap: (() -> Void)? = nil) {
        title = "플레이리스트 추가하기"
        songCount = 0
        artworkURLs = []
        kind = .add
        self.onTap = onTap
    }

    init(playlist: MusicPlaylist, onTap: (() -> Void)? = nil) {
        let musics = playlist.items
            .sorted { $0.addedAt < $1.addedAt }
            .compactMap(\.music)

        title = playlist.title
        songCount = musics.count
        artworkURLs = musics.prefix(4).map { $0.originalSong.artworkURL }
        kind = .playlist
        self.onTap = onTap
    }

    var body: some View {
        HStack(spacing: 20) {
            thumbnailView

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.pretendardSemiBold16)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if case .playlist = kind {
                    Text("곡 \(songCount)개")
                        .font(.pretendardSemiBold14)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.sheetDivider)
                .frame(height: 1)
        }
        .onTapGesture {
            onTap?()
        }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        switch kind {
        case .add:
            addThumbnail
        case .playlist:
            playlistThumbnail
        }
    }

    private var addThumbnail: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.addPlaylistButtonBackground)
            .frame(width: 52, height: 52)
            .overlay {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
    }

    private var playlistThumbnail: some View {
        PlaylistArtworkGridView(artworkURLs: artworkURLs)
    }
}
