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
    let karaokeNumber: String?
    var isPlaying: Bool = false
    
    // 재생 중 하이라이트 색상 (#FF29FF)
    private let accentMagenta = Color(hex: "FF29FF")
    
    var body: some View {
        HStack(spacing: 20) {
            CachedImageView(url: artworkURL)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // 재생 중이면 play 아이콘 + 마젠타 제목
                    HStack(spacing: 4) {
                        if isPlaying {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accentMagenta)
                        }
                        Text(title)
                            .foregroundStyle(isPlaying ? accentMagenta : .white)
                            .lineLimit(1)
                            .font(.pretendardSemiBold18)
                    }
                    Text(artistName).foregroundStyle(.gray).lineLimit(1).font(.pretendardSemiBold14)
                }
                Spacer()
                if let karaokeNumber {
                    Text(karaokeNumber)
                        .font(.pretendardSemiBold16)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .background(isPlaying ? Color.black.opacity(0.25) : Color.clear)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 25)
        }
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}
