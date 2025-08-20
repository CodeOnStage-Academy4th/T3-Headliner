//
//  MediaItemView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import ShazamKit

struct MediaItemView: View {
    // MARK: - Properties

    @EnvironmentObject var pathModel: PathModel
//    var viewModel: ShazamViewModel
    let mediaItem: SHMediaItem
    let showsRetryButton: Bool
    // closure
    var onRetry: (() -> Void)
    var onAddMusic: ((Music) async -> Void)

    // MARK: - Body

    var body: some View {
        ZStack {
            // 메인 컨텐츠 레이아웃
            VStack(spacing: 16) {
                mediaItemArtwork
                titleAndArtist

                MediaItemButtonsView(
                    showsRetryButton: showsRetryButton,
                    onRetry: handleRetry,
                    onAdd: handleAdd
                )
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

    // MARK: - UI Components

    @ViewBuilder
    private var mediaItemArtwork: some View {
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

    private var titleAndArtist: some View {
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
        .padding(.bottom, 40)
    }

    // MARK: - Actions

    private func handleRetry() {
        pathModel.paths.removeLast()
        pathModel.paths.append(.loading)
//        viewModel.retry()
        onRetry()
        
    }

    private func handleAdd() {
        Task {
            let music = mediaItem.toMusic()
//            await viewModel.addMusic(song: music)
            await onAddMusic(music) // 클로저 실행
            pathModel.removeAll()
        }
    }
}

// MARK: - Extension

extension SHMediaItem {
    /// SHMediaItem을 로컬 Music 모델로 변환
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
