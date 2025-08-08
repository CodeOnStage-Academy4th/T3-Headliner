//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI

struct MainListView: View {
    // TODO: 실제 데이터 연결 필요
//    let dummy: [Music] = (0..<10).map { i in
//        Music(id: "\(i)", title: "어제보다 슬픈 오늘", artistName: "마크툽",
//              artworkURL: nil, previewURL: nil)
//    }
    
    let playList: [PlaylistMusic]
    
    let viewTitle: String = "나의 뮤직 리스트"
    @Binding var isScrolled: Bool
    @Binding var scrollOffset: CGFloat
    
    var body: some View {
        ZStack {
            if playList.isEmpty {
                EmptyPlaylistView()
                    .background(
                        Image("EmptyBackground")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
            } else {
                LinearGradient.backgroundGradient
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    titleView
                    scrollView
                }
            }
        }
    }
    
    var titleView: some View {
        Text(viewTitle)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
            .padding(.top, 12)
    }
    
    var scrollView: some View {
        ScrollView {
            
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                scrollOffset = geo.frame(in: .global).minY
                                print("Initial scroll offset set: \(scrollOffset)")
                            }
                            .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                let offset = newValue
                                print("Current scroll offset: \(offset), Initial: \(scrollOffset)")
                                
                                // 초기 위치에서 50포인트 이상 위로 올라갔을 때 (스크롤 다운)
                                let shouldBeScrolled = offset < scrollOffset - 50
                                
                                if shouldBeScrolled != isScrolled {
                                    print("TabBar scale changing: \(isScrolled) -> \(shouldBeScrolled)")
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isScrolled = shouldBeScrolled
                                    }
                                }
                            }
                    }
                )
            LazyVStack(spacing: 0) {
                ForEach(playList) { t in
                    MusicRowView(title: t.originalSong.title,
                                 artistName: t.originalSong.artistName,
                                 artworkURL: t.originalSong.artworkURL,
                                 previewURL: t.originalSong.previewURL)
                }
            }
        }
        
    }
}

private struct EmptyPlaylistView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("EmptyMic")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .accessibilityHidden(true)

            Text("아직 저장된 노래가 없어요")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("검색으로 나만의 노래 리스트를\n만들어보아요")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 배경 그라디언트는 상위에서 이미 깔려 있음
    }
}
