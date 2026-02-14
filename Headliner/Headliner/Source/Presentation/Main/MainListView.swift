//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftData
import SwiftUI

enum KaraokeType: String, CaseIterable {
    case tj = "TJ"
    case ky = "KY"
}

struct MainListView: View {
    @Query(sort: \PlaylistMusic.originalSong.title) private var playlists: [PlaylistMusic]
    @Environment(AudioPreviewManager.self) private var audioManager
    
    var viewModel: PlaylistViewModel
    let viewTitle: String = "나의 뮤직 리스트"
    
    @Binding var isScrolled: Bool
    @State private var previousScrollOffset: CGFloat = 0
    @State private var selectedType: KaraokeType = .tj
    
    private let scrollThreshold: CGFloat = 20
    
    // 선택된 타입에 따라 표시할 노래번호를 결정
    private func getKaraokeNumber(for playlist: PlaylistMusic) -> String {
        if selectedType == .tj {
            return playlist.tjNumber ?? ""
        } else {
            return playlist.kyNumber ?? ""
        }
    }
    
    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea(.all)
            
            if playlists.isEmpty {
                MusicListEmptyView()
            } else {
                musicListView
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
        .onAppear {
            isScrolled = false
            previousScrollOffset = 0
        }
    }
    
    var musicListView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                titleHeaderView
                scrollView
            }
            bottomDeemedlayer
        }
    }
    
    var titleHeaderView: some View {
        HStack(alignment: .center) {
            Text(viewTitle)
                .font(.pretendardBold20)
                .foregroundStyle(.white)
            
            Spacer()
            
            segmentPicker
        }
        .padding(.top, 40)
        .padding(.horizontal, 25)
        .padding(.bottom, 20)
    }
    
    var segmentPicker: some View {
        let items = KaraokeType.allCases
        let width: CGFloat = 60
        let height: CGFloat = 36
        let padding: CGFloat = 4
        
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(
                    width: width * CGFloat(items.count) + padding * 2,
                    height: height + padding * 2
                )
            
            Capsule()
                .fill(Color.white)
                .frame(width: width, height: height)
                .offset(
                    x: CGFloat(items.firstIndex(of: selectedType) ?? 0) * width + padding
                )
                .animation(.easeInOut(duration: 0.2), value: selectedType)
            
            HStack(spacing: 0) {
                ForEach(items, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        Text(type.rawValue)
                            .font(.pretendardSemiBold16)
                            .foregroundStyle(selectedType == type ? .black : .white)
                            .frame(width: width, height: height)
                    }
                }
            }
            .padding(4)
        }
    }
  
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists, id: \.id) { t in
                    let index = playlists.firstIndex(where: { $0.id == t.id }) ?? 0
                    let isCurrent = audioManager.currentSong?.id == t.originalSong.id
                        && audioManager.isPlaying
                    
                    MusicRowView(title: t.originalSong.title,
                                 artistName: t.originalSong.artistName,
                                 artworkURL: t.originalSong.artworkURL,
                                 karaokeNumber: getKaraokeNumber(for: t),
                                 isPlaying: isCurrent)
                        .onTapGesture {
                            audioManager.play(song: t.originalSong)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                viewModel.deleteItems(
                                    at: IndexSet(integer: index),
                                    from: playlists
                                )
                            } label: {
                                Image(.delete)
                                    .offset(x: 3)
                            }
                            .tint(.clear)
                        }
                        .enableScrollViewSwipeActions()
                }
                
                // 미니 플레이어가 보일 때 하단 여백
                if audioManager.currentSong != nil {
                    Spacer()
                        .frame(height: 80)
                }
            }
            .scrollTargetLayout()
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            let delta = newValue - previousScrollOffset
            
            if delta > scrollThreshold {
                // 아래로 스크롤 (content가 위로 올라감)
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = true
                }
            } else if delta < -scrollThreshold {
                // 위로 스크롤 (content가 아래로 내려감)
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = false
                }
            }
            
            previousScrollOffset = newValue
        }
    }
    
    private var backgroundView: some View {
        GeometryReader { proxy in
            Image(.emptyBackground)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width,
                       height: proxy.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var bottomDeemedlayer: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(1),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 200)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
