//
//  MediaItemView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import ShazamKit

struct MediaItemView: View {
    let mediaItem: SHMediaItem

    var body: some View {
        VStack(spacing: 16) {
            artwork
            VStack(spacing: 6) {
                Text(mediaItem.title ?? "Unknown track")
                    .font(.system(size: 24, weight: .heavy))
                    .multilineTextAlignment(.center)
                Text(mediaItem.artist ?? "Unknown artist")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var artwork: some View {
        if let url = mediaItem.artworkURL {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.secondary.opacity(0.15))
            }
            .frame(width: 280, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(radius: 10)
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.secondary.opacity(0.15))
                .frame(width: 280, height: 280)
        }
    }
}

#Preview {
    let item = SHMediaItem(properties: [
        .title: "어제보다 슬픈 오늘",
        .artist: "마크툽",
        .artworkURL: URL(string: "https://picsum.photos/512")!
    ])

    return ZStack {
        LinearGradient(colors: [Color(red: 0.08, green: 0.10, blue: 0.18),
                                Color(red: 0.03, green: 0.02, blue: 0.06)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        MediaItemView(mediaItem: item)
            .padding(.vertical, 24)
    }
    .preferredColorScheme(.dark)
}
