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
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.08))
                // AsyncImage(url: artworkURL) { ... }
                Image(systemName: "music.note")
                    .imageScale(.large)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).foregroundStyle(.white).lineLimit(1)
                Text(artistName).font(.footnote).foregroundStyle(.gray).lineLimit(1)
                Divider()
                    .background(.gray)
            }
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MusicRowView(title: "어제보다 슬픈 오늘", artistName: "마크툽", artworkURL: nil, previewURL: nil)
}
