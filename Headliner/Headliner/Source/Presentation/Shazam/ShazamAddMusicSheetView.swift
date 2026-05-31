//
//  ShazamAddMusicSheetView.swift
//  Headliner
//
//  검색 결과 곡을 라이브러리(전체) 및 플레이리스트에 추가하는 시트
//

import MusicKit
import SwiftData
import SwiftUI

struct ShazamAddMusicSheetView: View {
    @Query(sort: \MusicPlaylist.createdAt) private var playlists: [MusicPlaylist]
    @Query private var allMusics: [PlaylistMusic]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let song: Song
    @ObservedObject var shazamViewModel: ShazamViewModel
    let playlistViewModel: PlaylistViewModel

    @State private var selectedPlaylistIDs: Set<String> = []
    @State private var isCreatePlaylistPresented = false

    /// 검색 곡과 동일한(title+artist) 라이브러리 항목. 이미 추가된 경우에만 존재.
    private var existingMusic: PlaylistMusic? {
        allMusics.first {
            $0.originalSong.title == song.title
                && $0.originalSong.artistName == song.artistName
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                grabber
                header

                allMusicRow

                playlistSection
            }

            addButton
                .padding(.bottom, 24)
        }
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.35),
                                    Color.black.opacity(0.65)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
        }
        .sheet(isPresented: $isCreatePlaylistPresented) {
            CreatePlaylistSheetView(
                defaultTitle: playlistViewModel.nextDefaultPlaylistTitle(from: playlists),
                viewModel: playlistViewModel
            ) { playlist in
                selectedPlaylistIDs.insert(playlist.id)
            }
            .presentationDetents([.height(788)])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Grabber

    private var grabber: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.sheetGrabber)
                .frame(width: 36, height: 5)
                .padding(.top, 5)

            Spacer(minLength: 0)
        }
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("뮤직 추가하기")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.sheetCloseButtonBackground)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 25)
    }

    // MARK: - 전체 (라이브러리) Row

    private var allMusicRow: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("전체")
                    .font(.pretendardSemiBold16)
                    .foregroundStyle(.white)

                Text("곡 \(allMusics.count)개")
                    .font(.pretendardSemiBold14)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // 전체는 항상 체크 (라이브러리에 항상 추가됨)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.accentMagenta)
                .frame(width: 52, height: 52)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.sheetDivider)
                .frame(height: 1)
        }
    }

    // MARK: - Playlist Section

    private var playlistSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("내 플레이리스트")
                    .font(.pretendardSemiBold14)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    selectedPlaylistIDs.removeAll()
                } label: {
                    Text("모두 지우기")
                        .font(.pretendardSemiBold14)
                        .foregroundStyle(Color.accentMagenta)
                }
                .buttonStyle(.plain)
                .disabled(selectedPlaylistIDs.isEmpty)
                .opacity(selectedPlaylistIDs.isEmpty ? 0.4 : 1)
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            .padding(.bottom, 4)

            ScrollView {
                LazyVStack(spacing: 0) {
                    addPlaylistRow

                    ForEach(playlists, id: \.id) { playlist in
                        SelectPlaylistRowView(
                            playlist: playlist,
                            isChecked: isChecked(playlist),
                            isLocked: isLocked(playlist)
                        ) {
                            toggleSelection(for: playlist)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 100)
            }
        }
    }

    private var addPlaylistRow: some View {
        Button {
            isCreatePlaylistPresented = true
        } label: {
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.addPlaylistButtonBackground)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                Text("플레이리스트 추가하기")
                    .font(.pretendardSemiBold16)
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 25)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.sheetDivider)
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            Task {
                let music = await shazamViewModel.addSong(song: song, context: context)
                    ?? existingMusic

                if let music {
                    playlistViewModel.addMusic(
                        music,
                        toPlaylistsWithIds: selectedPlaylistIDs,
                        from: playlists
                    )
                }

                shazamViewModel.addedSongIDs.insert(song.id)
                dismiss()
            }
        } label: {
            Text("추가하기")
                .font(.system(size: 18, weight: .medium))
        }
        .buttonStyle(CustomButtonStyle())
    }

    // MARK: - Selection Helpers

    private func isChecked(_ playlist: MusicPlaylist) -> Bool {
        if let existingMusic,
           playlistViewModel.isMusic(existingMusic, includedIn: playlist) {
            return true
        }
        return selectedPlaylistIDs.contains(playlist.id)
    }

    private func isLocked(_ playlist: MusicPlaylist) -> Bool {
        guard let existingMusic else { return false }
        return playlistViewModel.isMusic(existingMusic, includedIn: playlist)
    }

    private func toggleSelection(for playlist: MusicPlaylist) {
        guard !isLocked(playlist) else { return }

        if selectedPlaylistIDs.contains(playlist.id) {
            selectedPlaylistIDs.remove(playlist.id)
        } else {
            selectedPlaylistIDs.insert(playlist.id)
        }
    }
}
