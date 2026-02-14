//
//  AudioPreviewManager.swift
//  Headliner
//
//

import AVFoundation
import Observation

@MainActor
@Observable
final class AudioPreviewManager {
    var currentSong: Song?
    var isPlaying: Bool = false
    var progress: Double = 0.0 // 0.0 ~ 1.0
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    
    init() {
        configureAudioSession()
    }
    
    /// 곡 미리듣기 재생
    func play(song: Song) {
        guard let previewURL = song.previewURL else { return }
        
        // 같은 곡을 다시 탭하면 토글
        if currentSong?.id == song.id {
            togglePlayPause()
            return
        }
        
        // 기존 재생 정리
        cleanUp()
        
        let playerItem = AVPlayerItem(url: previewURL)
        player = AVPlayer(playerItem: playerItem)
        currentSong = song
        isPlaying = true
        progress = 0.0
        
        player?.play()
        
        addTimeObserver()
        addEndObserver()
    }
    
    /// 일시정지
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    /// 재개
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    /// 재생/일시정지 토글
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    /// 정지 및 초기화
    func stop() {
        cleanUp()
        currentSong = nil
        isPlaying = false
        progress = 0.0
    }
    
    // MARK: - Private Methods
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("[AudioPreviewManager] 오디오 세션 설정 실패: \(error)")
            #endif
        }
    }
    
    /// 재생 진행률 타이머 옵저버
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self,
                      let duration = self.player?.currentItem?.duration,
                      duration.seconds.isFinite,
                      duration.seconds > 0 else { return }
                
                self.progress = time.seconds / duration.seconds
            }
        }
    }
    
    /// 재생 완료 시 자동 정지
    private func addEndObserver() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
        }
    }
    
    /// 리소스 정리
    private func cleanUp() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        
        player?.pause()
        player = nil
    }
}
