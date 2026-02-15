//
//  MiniPlayerView.swift
//  Headliner
//
//  미리듣기 미니 플레이어 (하단 플로팅)
//

import SwiftUI

struct MiniPlayerView: View {
    @Environment(AudioPreviewManager.self) private var audioManager
    
    var body: some View {
        if let song = audioManager.currentSong {
            VStack(spacing: 6) {
                HStack {
                    HStack(spacing: 20) {
                        CachedImageView(url: song.artworkURL)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(song.title)
                                .font(.pretendardSemiBold14)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            
                            Text(song.artistName)
                                .font(.pretendardSemiBold10)
                                .foregroundStyle(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // 컨트롤 버튼
                    HStack(spacing: 10) {
                        // Play / Pause 토글
                        Button {
                            audioManager.togglePlayPause()
                        } label: {
                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        
                        // Close 버튼
                        Button {
                            audioManager.stop()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                    }
                }
                
                // MARK: - 프로그레스 바

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 배경 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 2)
                        
                        // 진행 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(
                                width: geometry.size.width * audioManager.progress,
                                height: 2
                            )
                            .animation(.linear(duration: 0.1), value: audioManager.progress)
                    }
                }
                .frame(height: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .frame(width: 343)
            .modifier(MiniPlayerBackgroundModifier())
        }
    }
}

// MARK: - 배경 모디파이어 (iOS 26: Liquid Glass / 이전: ultraThinMaterial)

private struct MiniPlayerBackgroundModifier: ViewModifier {
    private let shape = RoundedRectangle(cornerRadius: 40)
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
        }
    }
}
