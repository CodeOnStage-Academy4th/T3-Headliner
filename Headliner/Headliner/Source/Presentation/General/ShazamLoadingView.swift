//
//  ShazamLoadingView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI
import AVKit

struct ShazamLoadingView: View {
    
    @StateObject private var loopingPlayer = LoopingPlayer(videoName: "background")
    
    var body: some View {
        GeometryReader { proxy in
            // 1) VideoPlayer를 전체 화면에 깔기
            ZStack {
                VideoPlayer(player: loopingPlayer.player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .allowsHitTesting(false)
                    .onAppear {
                        loopingPlayer.player.play()
                    }
                
                VStack(spacing: 20) {
                    Image(.shazamButton)
                        .resizable()
                        .frame(width: 220, height: 220)
                    
                    VStack(spacing: 12) {
                        Text("검색 중")
                            .font(.pretendardBold20)
                            .foregroundColor(.white)
                        
                        Text("기기에 곡이 제대로 인식되는지 확인하세요")
                            .font(.pretendardMedium16)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: 100)
                }
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ShazamLoadingView()
}
