//
//  PlaylistEditSheetView.swift
//  Headliner
//
//  플레이리스트 편집(연필) 액션 시트 — 이름 변경 / 삭제
//

import SwiftUI

struct PlaylistEditSheetView: View {
    let playlist: MusicPlaylist
    let onRenameTap: () -> Void
    let onDeleteTap: () -> Void

    private let destructiveColor = Color(hex: "EB4B4B")
    private let dividerColor = Color.sheetDivider

    private var songCount: Int {
        (playlist.items ?? []).compactMap(\.music).count
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber

            playlistRow
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(dividerColor)
                        .frame(height: 1)
                }

            actionList
                .padding(.vertical, 10)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Grabber

    private var grabber: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.sheetGrabber)
                .frame(width: 36, height: 5)
                .padding(.top, 5)

            Spacer(minLength: 0)
        }
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
    }

    // MARK: - Playlist Row

    private var playlistRow: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(playlist.title)
                    .font(.pretendardSemiBold18)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("곡 \(songCount)개")
                    .font(.pretendardSemiBold14)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    // MARK: - Action List

    private var actionList: some View {
        VStack(spacing: 0) {
            actionRow(
                systemImage: "pencil.circle",
                text: "플레이리스트 이름 변경하기",
                tint: .white
            ) {
                onRenameTap()
            }

            actionRow(
                systemImage: "minus.circle",
                text: "플레이리스트 삭제하기",
                tint: destructiveColor
            ) {
                onDeleteTap()
            }
        }
    }

    private func actionRow(
        systemImage: String,
        text: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)

                Text(text)
                    .font(.pretendardSemiBold16)
                    .foregroundStyle(tint)

                Spacer()
            }
            .padding(20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
