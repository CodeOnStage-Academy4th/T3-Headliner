//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftData
import SwiftUI

struct MainListView: View {
    private enum MainSheet: Identifiable {
        case musicAction(PlaylistMusic)
        case createPlaylist
        case selectPlaylist(PlaylistMusic)

        var id: String {
            switch self {
            case .musicAction(let music):
                "musicAction-\(music.id)"
            case .createPlaylist:
                "createPlaylist"
            case .selectPlaylist(let music):
                "selectPlaylist-\(music.id)"
            }
        }
    }

    // MARK: - Properties
    @Query private var playlists: [PlaylistMusic]
    @Query(sort: \MusicPlaylist.createdAt) private var musicPlaylists: [MusicPlaylist]
    @Environment(AudioPreviewManager.self) private var audioManager

    var viewModel: PlaylistViewModel
    @Binding var isScrolled: Bool

    @State private var previousScrollOffset: CGFloat = 0
    @State private var selectedFilter: MusicFilterType = .all
    @State private var activeSheet: MainSheet?
    @State private var navigationPath: [PathType] = []

    private let scrollThreshold: CGFloat = 20

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundView.ignoresSafeArea(.all)
                musicListView
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .tabBar)
            .navigationDestination(for: PathType.self) { pathType in
                switch pathType {
                case .playlistDetail(let playlist):
                    PlaylistDetailView(
                        playlist: playlist,
                        viewModel: viewModel
                    )
                case .loading, .result:
                    EmptyView()
                }
            }
            .onAppear {
                isScrolled = false
                previousScrollOffset = 0
            }
            .sheet(item: $activeSheet) { sheet in
                sheetView(for: sheet)
            }
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
                selectedListContent

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

    // MARK: - Selected List Content
    @ViewBuilder
    private var selectedListContent: some View {
        switch selectedFilter {
        case .all:
            allMusicContent
        case .playlist:
            playlistContent
        }
    }

    @ViewBuilder
    private var allMusicContent: some View {
        if playlists.isEmpty {
            MusicListEmptyView()
                .frame(height: 520)
        } else {
            ForEach(playlists, id: \.id) { t in
                musicRow(for: t)
            }
        }
    }

    private var playlistContent: some View {
        VStack(spacing: 0) {
            PlaylistFolderRowView {
                activeSheet = .createPlaylist
            }

            ForEach(musicPlaylists, id: \.id) { playlist in
                PlaylistFolderRowView(playlist: playlist) {
                    navigationPath.append(.playlistDetail(playlist))
                }
            }
        }
    }

    // MARK: - Music Row
    @ViewBuilder
    private func musicRow(for t: PlaylistMusic) -> some View {
        let isCurrent = audioManager.currentSong?.id == t.originalSong?.id && audioManager.isPlaying

        MusicRowView(
            title: t.originalSong?.title ?? "",
            artistName: t.originalSong?.artistName ?? "",
            artworkURL: t.originalSong?.artworkURL,
            tjNumber: t.tjNumber,
            kyNumber: t.kyNumber,
            isPlaying: isCurrent,
            onMoreTap: {
                activeSheet = .musicAction(t)
            }
        )
        .onTapGesture {
            if let song = t.originalSong {
                audioManager.play(song: song)
            }
        }
    }

    // MARK: - Sheet
    @ViewBuilder
    private func sheetView(for sheet: MainSheet) -> some View {
        switch sheet {
        case .musicAction(let music):
            MusicActionSheetView(
                music: music,
                onAddToPlaylistTap: {
                    activeSheet = .selectPlaylist(music)
                },
                onDeleteTap: {
                    viewModel.deleteMusicFromLibrary(music)
                }
            )
            .presentationDetents([.height(215)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
            .preferredColorScheme(.dark)

        case .createPlaylist:
            CreatePlaylistSheetView(
                defaultTitle: viewModel.nextDefaultPlaylistTitle(from: musicPlaylists),
                viewModel: viewModel
            )
            .presentationDetents([.height(788)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)

        case .selectPlaylist(let music):
            SelectPlaylistSheetView(
                music: music,
                viewModel: viewModel
            )
            .presentationDetents([.height(720)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
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
        .allowsHitTesting(false)
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
