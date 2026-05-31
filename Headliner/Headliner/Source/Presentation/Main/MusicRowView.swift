//
//  MusicRowView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI

struct MusicRowView: View {
    let title: String
    let artistName: String
    let artworkURL: URL?
    let tjNumber: String?
    let kyNumber: String?
    var isPlaying: Bool = false
    var onMoreTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 20) {
            CachedImageView(url: artworkURL)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                // 재생 중이면 play 아이콘 + 마젠타 제목
                HStack(spacing: 4) {
                    if isPlaying {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.accentMagenta)
                    }
                    Text(title)
                        .foregroundStyle(isPlaying ? Color.accentMagenta : .white)
                        .lineLimit(1)
                        .font(.pretendardSemiBold18)
                }

                Text(artistName)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .font(.pretendardMedium14)

                karaokeNumberRow
            }

            Spacer()

            moreButton
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .background(isPlaying ? Color.black.opacity(0.25) : Color.clear)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(height: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }

    // MARK: - Karaoke Number Row
    @ViewBuilder
    private var karaokeNumberRow: some View {
        let hasTJ = !(tjNumber?.isEmpty ?? true)
        let hasKY = !(kyNumber?.isEmpty ?? true)

        if hasTJ || hasKY {
            HStack(spacing: 10) {
                if hasTJ, let tjNumber {
                    karaokeNumberItem(label: "TJ", number: tjNumber)
                }

                if hasTJ && hasKY {
                    Text("|")
                        .font(.pretendardRegular14)
                        .foregroundStyle(.white.opacity(0.25))
                }

                if hasKY, let kyNumber {
                    karaokeNumberItem(label: "KY", number: kyNumber)
                }
            }
        }
    }

    private func karaokeNumberItem(label: String, number: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.pretendardMedium14)
                .foregroundStyle(.white.opacity(0.6))
            Text(number)
                .font(.pretendardSemiBold14)
                .foregroundStyle(.white)
        }
    }

    // MARK: - More Button (점 세개)
    private var moreButton: some View {
        Button {
            onMoreTap?()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 48, height: 48)
                .contentShape(Rectangle())
        }
    }
}
