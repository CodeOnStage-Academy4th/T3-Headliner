//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftData
import SwiftUI

struct MainListView: View {
    // MARK: - Properties
    @Query(sort: \PlaylistMusic.originalSong.title) private var playlists: [PlaylistMusic]
    @Environment(AudioPreviewManager.self) private var audioManager

    var viewModel: PlaylistViewModel
    @Binding var isScrolled: Bool

    @State private var previousScrollOffset: CGFloat = 0
    @State private var selectedFilter: MusicFilterType = .all
    @State private var selectedMusicForMenu: PlaylistMusic?

    private let scrollThreshold: CGFloat = 20

    // MARK: - Body
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
        .sheet(item: $selectedMusicForMenu) { music in
            MusicActionSheetView(music: music)
                .presentationDetents([.height(215)])
                .presentationCornerRadius(34)
                .presentationDragIndicator(.hidden)
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Music List View
    private var musicListView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                titleHeaderView
                MusicFilterSegmentView(selection: $selectedFilter)
                    .padding(.bottom, 10)
                musicScrollView
            }
            bottomDimmedLayer
        }
    }

    // MARK: - Title Header
    private var titleHeaderView: some View {
        Text("나의 뮤직 리스트")
            .font(.pretendardBold20)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 28)
            .padding(.horizontal, 25)
            .padding(.bottom, 10)
    }

    // MARK: - Music Scroll View
    private var musicScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists, id: \.id) { t in
                    musicRow(for: t)
                }

                // 하단 여백: 탭바/그라디언트 영역 확보
                Spacer()
                    .frame(height: 100)
            }
            .scrollTargetLayout()
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            handleScroll(offset: newValue)
        }
    }

    // MARK: - Music Row
    @ViewBuilder
    private func musicRow(for t: PlaylistMusic) -> some View {
        let isCurrent = audioManager.currentSong?.id == t.originalSong.id && audioManager.isPlaying

        MusicRowView(
            title: t.originalSong.title,
            artistName: t.originalSong.artistName,
            artworkURL: t.originalSong.artworkURL,
            tjNumber: t.tjNumber,
            kyNumber: t.kyNumber,
            isPlaying: isCurrent,
            onMoreTap: {
                selectedMusicForMenu = t
            }
        )
        .onTapGesture {
            audioManager.play(song: t.originalSong)
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        GeometryReader { proxy in
            Image(.emptyBackground)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }

    // MARK: - Bottom Dimmed Layer
    private var bottomDimmedLayer: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(1),
                    .black.opacity(0.15),
                    .black.opacity(0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 200)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func handleScroll(offset: CGFloat) {
        let delta = offset - previousScrollOffset

        if delta > scrollThreshold {
            withAnimation(.easeInOut(duration: 0.3)) {
                isScrolled = true
            }
        } else if delta < -scrollThreshold {
            withAnimation(.easeInOut(duration: 0.3)) {
                isScrolled = false
            }
        }

        previousScrollOffset = offset
    }
}
