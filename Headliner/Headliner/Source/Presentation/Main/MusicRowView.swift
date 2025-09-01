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
    let previewURL: URL?
    let karaokeNumber: String?
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                CachedImageView(url: artworkURL)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title).foregroundStyle(.white).lineLimit(1).font(.pretendardSemiBold18)
                            Text(artistName).foregroundStyle(.gray).lineLimit(1).font(.pretendardSemiBold14)
                            
                        }
                        Spacer()
                        if let karaokeNumber {
                            Text(karaokeNumber)
                                .font(.pretendardSemiBold16)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.vertical, 10)
                    Divider()
                        .background(.gray)
                }
            }
            .background(Color.clear)
            .contentShape(Rectangle())
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
