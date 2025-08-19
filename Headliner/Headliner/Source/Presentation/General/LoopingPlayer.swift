//
//  LoopingPlayer.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import AVFoundation
import Foundation
import Combine // 1. Combine 프레임워크를 추가합니다.

// 2. ': ObservableObject' 를 추가하여 프로토콜을 따르도록 합니다.
final class LoopingPlayer: ObservableObject {
  let player: AVQueuePlayer
  private var looper: AVPlayerLooper?
  
  init(videoName: String, videoType: String = "mov") {
    // 1) 로컬 번들 혹은 URL로 AVPlayerItem 생성
    guard let url = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
      fatalError("비디오 파일을 찾을 수 없습니다.")
    }
    let asset = AVURLAsset(url: url)
    let item = AVPlayerItem(asset: asset)
    
    let queuePlayer = AVQueuePlayer(playerItem: item)
    self.player = queuePlayer
    self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    
    // 3) 사운드 제거, 끝났을 때 아무 동작도 취하지 않음
    player.isMuted = true
    player.actionAtItemEnd = .none
  }
}
