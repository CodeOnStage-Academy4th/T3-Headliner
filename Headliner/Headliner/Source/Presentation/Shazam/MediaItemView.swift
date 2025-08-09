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
    @EnvironmentObject var pathModel: PathModel

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                artwork
                VStack(spacing: 6) {
                    Text(mediaItem.title ?? "Unknown track")
                        .font(.pretendardBold20)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(mediaItem.artist ?? "Unknown artist")
                        .font(.pretendardSemiBold16)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("추가하기")
                    }
                    .buttonStyle(CustomButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
        }
        .background(
            Image("EmptyBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
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
            .frame(width: 240, height: 240)
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
