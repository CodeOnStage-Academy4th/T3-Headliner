//
//  PlaylistDetailView.swift
//  Headliner
//
//  플레이리스트 상세 화면 (헤더 + 곡 리스트)
//

import SwiftUI

struct PlaylistDetailView: View {
    let playlist: MusicPlaylist
    let viewModel: PlaylistViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(AudioPreviewManager.self) private var audioManager
    @State private var activeSheet: DetailSheet?

    private enum DetailSheet: Identifiable {
        case musicAction(PlaylistMusic)
        case selectPlaylist(PlaylistMusic)
        case editPlaylist
        case renamePlaylist

        var id: String {
            switch self {
            case .musicAction(let music): "musicAction-\(music.id)"
            case .selectPlaylist(let music): "selectPlaylist-\(music.id)"
            case .editPlaylist: "editPlaylist"
            case .renamePlaylist: "renamePlaylist"
            }
        }
    }

    private var musics: [PlaylistMusic] {
        playlist.items
            .sorted { $0.addedAt < $1.addedAt }
            .compactMap(\.music)
    }

    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea(.all)

            VStack(spacing: 0) {
                header
                musicScrollView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
        .sheet(item: $activeSheet) { sheet in
            sheetView(for: sheet)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(playlist.title)
                .font(.pretendardSemiBold18)
                .foregroundStyle(.white)
                .lineLimit(1)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    activeSheet = .editPlaylist
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Music Scroll View

    private var musicScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(musics, id: \.id) { music in
                    musicRow(for: music)
                }

                Spacer().frame(height: 100)
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private func musicRow(for music: PlaylistMusic) -> some View {
        let isCurrent = audioManager.currentSong?.id == music.originalSong.id && audioManager.isPlaying

        MusicRowView(
            title: music.originalSong.title,
            artistName: music.originalSong.artistName,
            artworkURL: music.originalSong.artworkURL,
            tjNumber: music.tjNumber,
            kyNumber: music.kyNumber,
            isPlaying: isCurrent,
            onMoreTap: {
                activeSheet = .musicAction(music)
            }
        )
        .onTapGesture {
            audioManager.play(song: music.originalSong)
        }
    }

    // MARK: - Sheet

    @ViewBuilder
    private func sheetView(for sheet: DetailSheet) -> some View {
        switch sheet {
        case .musicAction(let music):
            MusicActionSheetView(
                music: music,
                onAddToPlaylistTap: {
                    activeSheet = .selectPlaylist(music)
                },
                onDeleteTap: {
                    viewModel.removeMusic(music, from: playlist)
                }
            )
            .presentationDetents([.height(215)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
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

        case .editPlaylist:
            PlaylistEditSheetView(
                playlist: playlist,
                onRenameTap: {
                    activeSheet = .renamePlaylist
                },
                onDeleteTap: {
                    viewModel.deletePlaylist(playlist)
                    dismiss()
                }
            )
            .presentationDetents([.height(260)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
            .preferredColorScheme(.dark)

        case .renamePlaylist:
            CreatePlaylistSheetView(
                editing: playlist,
                viewModel: viewModel
            )
            .presentationDetents([.height(788)])
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
}
