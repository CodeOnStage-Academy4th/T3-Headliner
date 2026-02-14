//
//  SearchMusicRowView.swift
//  Headliner
//
//  Created by Henry on 2/13/26.
//

import SwiftUI

struct SearchMusicRowView: View {
    let title: String
    let artistName: String
    let artworkURL: URL?
    let isPlaying: Bool
    let isAdded: Bool
    let onPlay: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                HStack(spacing: 20) {
                    ZStack {
                        CachedImageView(url: artworkURL)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // 재생 중 오버레이
                        if isPlaying {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "pause.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // 제목 + 아티스트
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .font(.pretendardSemiBold18)
                        Text(artistName)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                            .font(.pretendardSemiBold14)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onPlay()
                }
                
                addButton
            }
            .padding(.vertical, 16)
            
            // 하단 구분선
            Divider()
                .background(.white.opacity(0.25))
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .padding(.horizontal, 25)
    }
    
    // MARK: - 추가 / 체크마크 버튼
    
    @ViewBuilder
    private var addButton: some View {
        if isAdded {
            // 이미 추가된 상태 - 체크마크
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0, green: 1, blue: 1).opacity(0.6))
                .frame(width: 60, height: 60)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            // 미추가 상태 - + 버튼
            Button {
                onAdd()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 60, height: 60)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
