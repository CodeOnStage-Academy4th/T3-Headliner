//
//  MediaItemView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import ShazamKit
import SwiftUI

struct MediaItemView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var container: DIContainer
    var viewModel: ShazamViewModel
    let mediaItem: SHMediaItem?
    let result: MusicSearchResult
    
    var body: some View {
        switch self.result.status {
        case .failure:
            ShazamSearchFailView(
                onRetry: self.viewModel.retry,
                onBack: self.viewModel.goToBack
            )
            
        case .complete:
            self.successContentView(showRetryButton: false)
            
        case .completeShazam:
            self.successContentView(showRetryButton: true)
        }
    }
    
    private func successContentView(showRetryButton: Bool) -> some View {
        ZStack {
            VStack(spacing: 16) {
                self.mediaItemArtwork
                self.titleAndArtist
                
                // 상태에 따른 버튼 표시
                self.buttonSection(showRetryButton: showRetryButton)
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
                    self.viewModel.goToBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }
    }
    
    @ViewBuilder
    private func buttonSection(showRetryButton: Bool) -> some View {
        if showRetryButton {
            // 추가하기 + 재시도 버튼
            VStack(spacing: 12) {
                Button {
                    self.handleAdd()
                } label: {
                    self.buttonView(icon: "plus", title: "추가하기")
                }
                .buttonStyle(CustomButtonStyle())
                
                Button {
                    self.viewModel.retry()
                } label: {
                    self.buttonView(icon: "arrow.counterclockwise", title: "재시도")
                }
                .buttonStyle(RetryButtonStyle())
            }
        } else {
            // 추가하기 버튼만
            Button {
                self.handleAdd()
            } label: {
                self.buttonView(icon: "plus", title: "추가하기")
            }
            .buttonStyle(CustomButtonStyle())
        }
    }
    
    private func buttonView(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.pretendardSemiBold18)
        }
    }
    
    @ViewBuilder
    private var mediaItemArtwork: some View {
        if let url = mediaItem?.artworkURL {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.secondary.opacity(0.15))
            }
            .frame(width: 240, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.secondary.opacity(0.15))
                .frame(width: 280, height: 280)
        }
    }
    
    private var titleAndArtist: some View {
        VStack(spacing: 6) {
            Text(self.result.title)
                .font(.pretendardBold20)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(self.result.artist)
                .font(.pretendardSemiBold16)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private func handleAdd() {
        Task {
            guard let song = mediaItem?.toSong() else {
                return
            }
            await self.viewModel.addSong(song: song, context: self.context)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                self.container.pathModel.removeAll()
                self.container.activeTab = .main
            }
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
