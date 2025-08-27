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
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var container: DIContainer
    var viewModel: ShazamViewModel
    let mediaItem: SHMediaItem
    let showsRetryButton: Bool
    // closure
    //    var onRetry: (() -> Void)
    //    var onAddMusic: ((Music) async -> Void)
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 메인 컨텐츠 레이아웃
            VStack(spacing: 16) {
                mediaItemArtwork
                titleAndArtist
                
                MediaItemButtonsView(
                    showsRetryButton: showsRetryButton,
                    onRetry: viewModel.retry,
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("goToBack()")
                    viewModel.goToBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }
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
    
    //    private func handleRetry() {
    ////        container.pathModel.paths.removeLast()
    ////        container.pathModel.paths.append(.loading)
    //        viewModel.retry()
    ////TODO: retry
    //    }
    
    private func handleAdd() {
        Task {
            let song = mediaItem.toSong()
            await viewModel.addSong(song: song, context: context)
            //            await onAddMusic(music) // 클로저 실행
//            container.pathModel.removeAll()
//            viewModel.goToPlaylist()
            // TODO: addMusic
            
            //            _ = container.managers.shazamManager.
        }
    }
}

// MARK: - Extension

extension SHMediaItem {
    /// SHMediaItem을 로컬 Song 모델로 변환
    func toSong() -> Song {
        Song(
            id: self.shazamID ?? UUID().uuidString,
            title: self.title ?? "제목 없음",
            artistName: self.artist ?? "아티스트 없음",
            artworkURL: self.artworkURL,
            previewURL: nil
        )
    }
}
