//
//  LoopingPlayer.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import AVFoundation
import Foundation
import SwiftUI
import AVKit


final class LoopingPlayer: ObservableObject {
    let player: AVQueuePlayer
    private var looper: AVPlayerLooper?
    
    init(videoName: String, videoType: String = "mov") {
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
            fatalError("비디오 파일을 찾을 수 없습니다.")
        }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: item)
        self.player = queuePlayer
        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        player.isMuted = true
        player.actionAtItemEnd = .none
    }
}

struct LoopingVideoBackground: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill  // ✅ 꽉 채우기
        playerLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(playerLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
