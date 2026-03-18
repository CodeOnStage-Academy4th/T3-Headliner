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
    // MARK: - Properties
    @Query(sort: \PlaylistMusic.originalSong.title) private var playlists: [PlaylistMusic]
    @Environment(AudioPreviewManager.self) private var audioManager

    var viewModel: PlaylistViewModel
    @Binding var isScrolled: Bool

    @State private var previousScrollOffset: CGFloat = 0
    @State private var selectedType: KaraokeType = .tj

    private let scrollThreshold: CGFloat = 20

    // MARK: - Segment Picker Constants
    private enum SegmentConstants {
        static let itemWidth: CGFloat = 60
        static let itemHeight: CGFloat = 36
        static let padding: CGFloat = 4
    }

    // MARK: - Helper Methods
    private func getKaraokeNumber(for playlist: PlaylistMusic) -> String {
        selectedType == .tj ? playlist.tjNumber ?? "" : playlist.kyNumber ?? ""
    }

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
    }

    // MARK: - Music List View
    private var musicListView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                titleHeaderView
                musicScrollView
            }
            bottomDimmedLayer
        }
    }

    // MARK: - Title Header
    private var titleHeaderView: some View {
        HStack(alignment: .center) {
            Text("나의 뮤직 리스트")
                .font(.pretendardBold20)
                .foregroundStyle(.white)

            Spacer()

            segmentPicker
        }
        .padding(.top, 40)
        .padding(.horizontal, 25)
        .padding(.bottom, 20)
    }

    // MARK: - Segment Picker
    private var segmentPicker: some View {
        let items = KaraokeType.allCases
        let selectedIndex = CGFloat(items.firstIndex(of: selectedType) ?? 0)

        return ZStack(alignment: .leading) {
            // Background
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(
                    width: SegmentConstants.itemWidth * CGFloat(items.count) + SegmentConstants.padding * 2,
                    height: SegmentConstants.itemHeight + SegmentConstants.padding * 2
                )

            // Indicator
            Capsule()
                .fill(Color.white)
                .frame(width: SegmentConstants.itemWidth, height: SegmentConstants.itemHeight)
                .offset(x: selectedIndex * SegmentConstants.itemWidth + SegmentConstants.padding)
                .animation(.easeInOut(duration: 0.2), value: selectedType)

            // Buttons
            HStack(spacing: 0) {
                ForEach(items, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        Text(type.rawValue)
                            .font(.pretendardSemiBold16)
                            .foregroundStyle(selectedType == type ? .black : .white)
                            .frame(width: SegmentConstants.itemWidth, height: SegmentConstants.itemHeight)
                    }
                }
            }
            .padding(SegmentConstants.padding)
        }
    }

    // MARK: - Music Scroll View
    private var musicScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists, id: \.id) { t in
                    musicRow(for: t)
                }

                // 하단 여백: 미니 플레이어 + 스와이프 버튼 공간
                Spacer()
                    .frame(height: audioManager.currentSong != nil ? 150 : 100)
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
        let index = playlists.firstIndex(where: { $0.id == t.id }) ?? 0
        let isCurrent = audioManager.currentSong?.id == t.originalSong.id && audioManager.isPlaying

        MusicRowView(
            title: t.originalSong.title,
            artistName: t.originalSong.artistName,
            artworkURL: t.originalSong.artworkURL,
            karaokeNumber: getKaraokeNumber(for: t),
            isPlaying: isCurrent
        )
        .onTapGesture {
            audioManager.play(song: t.originalSong)
        }
        .swipeActions {
            SwipeAction(
                symbolImage: UIImage(resource: .delete),
                size: CGSize(width: 60, height: 60),
                shape: AnyShape(RoundedRectangle(cornerRadius: 12))
            ) { resetPosition in
                viewModel.deleteItems(at: IndexSet(integer: index), from: playlists)
                resetPosition = true
            }
        }
        .enableScrollViewSwipeActions()
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
