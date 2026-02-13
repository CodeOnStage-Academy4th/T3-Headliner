//
//  SearchMusicRowView.swift
//  Headliner
//
//  Created by Henry on 2/13/26.
//

import SwiftUI

/// 검색 결과 전용 Row 뷰 (+ 버튼 / 체크마크 표시)
struct SearchMusicRowView: View {
    let title: String
    let artistName: String
    let artworkURL: URL?
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // 앨범 아트워크
                CachedImageView(url: artworkURL)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
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
                
                // 추가 / 체크마크 버튼
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
