//
//  MusicActionSheetView.swift
//  Headliner
//
//  MusicRow의 점 세개 버튼 탭 시 표시되는 액션 시트 (UI only)
//  Figma: node 819-6479 (Sheet - Inspector - iPhone)
//

import SwiftUI

struct MusicActionSheetView: View {
    let music: PlaylistMusic
    let onAddToPlaylistTap: () -> Void
    let onDeleteTap: () -> Void
    @Environment(\.dismiss) private var dismiss

    // 삭제 버튼 강조 색상 (#EB4B4B - Figma fill_53QOLV)
    private let destructiveColor = Color(hex: "EB4B4B")

    // 구분선 색상 (Figma fill_BE54GU - rgba(255,255,255,0.1))
    private let dividerColor = Color.sheetDivider

    var body: some View {
        VStack(spacing: 0) {
            grabber

            songRow
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

    // MARK: - Grabber (Figma: Toolbar)

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

    // MARK: - 선택된 곡 Row (Figma: Frame 65 inside Sheet)

    private var songRow: some View {
        HStack(spacing: 20) {
            CachedImageView(url: music.originalSong?.artworkURL)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                Text(music.originalSong?.title ?? "")
                    .font(.pretendardSemiBold18)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(music.originalSong?.artistName ?? "")
                    .font(.pretendardSemiBold14)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    // MARK: - 액션 목록 (Figma: Frame 1437255801)

    private var actionList: some View {
        VStack(spacing: 0) {
            actionRow(
                systemImage: "plus.circle",
                text: "플레이리스트에 추가하기",
                tint: .white
            ) {
                onAddToPlaylistTap()
            }

            actionRow(
                systemImage: "minus.circle",
                text: "삭제하기",
                tint: destructiveColor
            ) {
                dismiss()
                onDeleteTap()
            }
        }
    }

    // MARK: - 액션 Row (Figma: Frame 1437255799 / 1437255800)

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
