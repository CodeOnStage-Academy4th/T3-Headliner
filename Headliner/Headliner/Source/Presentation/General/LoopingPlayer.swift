//
//  LoopingPlayer.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import AVFoundation
import Foundation

final class LoopingPlayer {
  let player: AVQueuePlayer
  private var looper: AVPlayerLooper?
  
  init(videoName: String, videoType: String = "mov") {
    // 1) 로컬 번들 혹은 URL로 AVPlayerItem 생성
    guard let url = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
      fatalError("비디오 파일을 찾을 수 없습니다.")
    }
    let asset = AVAsset(url: url)
    let item = AVPlayerItem(asset: asset)
    
    // 2) AVQueuePlayer + looper
    self.player = AVQueuePlayer()
    self.looper = AVPlayerLooper(player: player, templateItem: item)
    
    // 3) 사운드 제거, 끝났을 때 아무 동작도 취하지 않음
    player.isMuted = true
    player.actionAtItemEnd = .none
  }
}
