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
    
    @Binding var isScrolled: Bool
    @Binding var scrollOffset: CGFloat
    
    @State private var scrolledID: PlaylistMusic.ID?
    
    var viewModel: PlaylistViewModel
    let viewTitle: String = "나의 뮤직 리스트"
    
    var body: some View {
        ZStack {
            backgroundView
            if playlists.isEmpty {
                MusicListEmptyView()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    titleView
                    scrollView
                }
                bottomDeemedlayer
            }
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
                ForEach(playlists) { t in
                    MusicRowView(title: t.originalSong.title,
                                 artistName: t.originalSong.artistName,
                                 artworkURL: t.originalSong.artworkURL,
                                 previewURL: t.originalSong.previewURL,
                                 karaokeNumber: t.karaokeNumber)
                    .swipeActions(edge: .trailing) {
                        Button {
                            
                        } label: {
                            // TODO: Custom Button으로 수정하기 & 간격
//                            Image(systemName: "trash")
//                                .frame(width: 70, height: 70)
//                                .foregroundStyle(.white.opacity(0.6))
//                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
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
        LinearGradient.backgroundGradient.ignoresSafeArea(.all)
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
