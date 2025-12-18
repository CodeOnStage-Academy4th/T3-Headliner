//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import SwiftData

struct MainListView: View {
    
    @Query(sort: \PlaylistMusic.originalSong.title) private var playlists: [PlaylistMusic]
    
    var viewModel: PlaylistViewModel
    let viewTitle: String = "나의 뮤직 리스트"
    
    @Binding var isScrolled: Bool
    @State private var previousScrollOffset: CGFloat = 0
    
    private let scrollThreshold: CGFloat = 20
    
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
                titleView
                scrollView
            }
            bottomDeemedlayer
        }
    }
    
    var titleView: some View {
        Text(viewTitle)
            .font(.pretendardBold20)
            .foregroundStyle(.white)
            .padding(.top, 40)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists, id: \.id) { t in
                    let index = playlists.firstIndex(where: { $0.id == t.id }) ?? 0
                    
                    MusicRowView(title: t.originalSong.title,
                                 artistName: t.originalSong.artistName,
                                 artworkURL: t.originalSong.artworkURL,
                                 previewURL: t.originalSong.previewURL,
                                 karaokeNumber: t.karaokeNumber)
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
            }
            .scrollTargetLayout()
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldValue, newValue in
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
