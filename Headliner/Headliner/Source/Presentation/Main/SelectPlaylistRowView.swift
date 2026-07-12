//
//  SelectPlaylistRowView.swift
//  Headliner
//
//  곡 추가 시트의 플레이리스트 선택 Row
//

import SwiftUI

struct SelectPlaylistRowView: View {
    let playlist: MusicPlaylist
    let isChecked: Bool
    let isLocked: Bool
    let onTap: () -> Void

    private var musics: [PlaylistMusic] {
        (playlist.items ?? [])
            .sorted { $0.addedAt < $1.addedAt }
            .compactMap(\.music)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                PlaylistArtworkGridView(
                    artworkURLs: musics.prefix(4).map { $0.originalSong?.artworkURL }
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(playlist.title)
                        .font(.pretendardSemiBold16)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("곡 \(musics.count)개")
                        .font(.pretendardSemiBold14)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isChecked ? Color.accentMagenta : .white.opacity(0.6))
                    .frame(width: 52, height: 52)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 25)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.sheetDivider)
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
}
