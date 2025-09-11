//
//  ShazamLoadingView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI
import AVKit

struct ShazamLoadingView: View {
    
    @ObservedObject var viewModel: ShazamViewModel
    @StateObject private var loopingPlayer = LoopingPlayer(videoName: "background")
    
    var body: some View {
        GeometryReader { proxy in
            // 1) VideoPlayer를 전체 화면에 깔기
            ZStack {
                LinearGradient.backgroundGradient
                LoopingVideoBackground(player: loopingPlayer.player)
                    .ignoresSafeArea()
                    .onAppear {
                        loopingPlayer.player.play()
                    }
                
                VStack(spacing: 20) {
                    Image(.shazamButton)
                        .resizable()
                        .frame(width: 220, height: 220)
                        .padding(.top, 60)
                    
                    VStack(spacing: 12) {
                        Text("검색 중")
                            .font(.pretendardBold20)
                            .foregroundColor(.white)
                        
                        Text("기기에 곡이 제대로 인식되는지 확인하세요")
                            .font(.pretendardMedium16)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button {
                            viewModel.goToBack()
                        } label: {
                            Text("취소하기")
                        }
                        .buttonStyle(RetryButtonStyle())
                    }
                    .offset(y: 100)
                }
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden()
    }
}

