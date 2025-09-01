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
    @State private var scrolledID: PlaylistMusic.ID?
    
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
        .scrollPosition(id: $scrolledID)
        .onChange(of: scrolledID) { oldValue, newValue in
            if scrolledID != playlists.first?.id {
                // Soop TODO: - 중복 코드 수정하기
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = false
                }
            }
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
