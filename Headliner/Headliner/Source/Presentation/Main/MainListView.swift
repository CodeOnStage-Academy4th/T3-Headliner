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
        .padding(.bottom, 20)    }
    
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
                ForEach(playlists) { t in
                    MusicRowView(title: t.originalSong.title,
                                 artistName: t.originalSong.artistName,
                                 artworkURL: t.originalSong.artworkURL,
                                 previewURL: t.originalSong.previewURL,
                                 karaokeNumber: t.karaokeNumber)
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
