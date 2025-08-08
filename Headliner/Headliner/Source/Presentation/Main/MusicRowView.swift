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

    var body: some View {
        HStack(spacing: 20) {
            // AsyncImage(url: artworkURL) { ... }
            Image(systemName: "music.note")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.white.opacity(0.8))
        
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title).foregroundStyle(.white).lineLimit(1).font(.pretendardSemiBold18)
                        Text(artistName).foregroundStyle(.gray).lineLimit(1).font(.pretendardSemiBold14)
                        
                    }
                    Spacer()
                    Text("12345")
                        .font(.pretendardSemiBold16)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.vertical, 10)
                Divider()
                    .background(.gray)
            }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MusicRowView(title: "어제보다 슬픈 오늘", artistName: "마크툽", artworkURL: nil, previewURL: nil)
}
