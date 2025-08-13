//
//  MediaItemView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import ShazamKit

struct MediaItemView: View {
    @EnvironmentObject var pathModel: PathModel
    @EnvironmentObject var shazamVM: ShazamViewModel
    let mediaItem: SHMediaItem

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
                        Task {
                            let music = mediaItem.toMusic()
                            await shazamVM.addMusic(song: music)
                        }
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

extension SHMediaItem {
    func toMusic() -> Music {
        Music(
            id: self.shazamID ?? UUID().uuidString,
            title: self.title ?? "제목 없음",
            artistName: self.artist ?? "아티스트 없음",
            artworkURL: self.artworkURL,
            previewURL: nil
        )
    }
}