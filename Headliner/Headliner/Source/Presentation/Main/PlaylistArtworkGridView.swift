//
//  PlaylistArtworkGridView.swift
//  Headliner
//
//  플레이리스트 상위 4곡 앨범 커버 그리드
//

import SwiftUI

struct PlaylistArtworkGridView: View {
    let artworkURLs: [URL?]

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.playlistArtworkBackground)

            ForEach(Array(artworkURLs.prefix(4).enumerated()), id: \.offset) { index, url in
                CachedImageView(url: url)
                    .frame(width: 26, height: 26)
                    .clipped()
                    .offset(
                        x: index.isMultiple(of: 2) ? 0 : 26,
                        y: index < 2 ? 0 : 26
                    )
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
