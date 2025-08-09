//
//  ShazamLoadingView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI
import AVKit

struct ShazamLoadingView: View {
    
    private let loopingPlayer = LoopingPlayer(videoName: "background")
    
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
                VStack {
                    Image(.shazamButton)
                        .resizable()
                        .frame(width: 220, height: 220)
                    Spacer()
                        .frame(height: 70)
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
