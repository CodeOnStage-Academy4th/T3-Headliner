//
//  SelectPlaylistSheetView.swift
//  Headliner
//
//  곡을 추가할 플레이리스트 선택 시트
//

import SwiftData
import SwiftUI

struct SelectPlaylistSheetView: View {
    @Query(sort: \MusicPlaylist.createdAt) private var playlists: [MusicPlaylist]
    @Environment(\.dismiss) private var dismiss

    let music: PlaylistMusic
    let viewModel: PlaylistViewModel

    @State private var selectedPlaylistIDs: Set<String> = []
    @State private var isCreatePlaylistPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                grabber
                header

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
                defaultTitle: viewModel.nextDefaultPlaylistTitle(from: playlists),
                viewModel: viewModel,
                initialMusic: music
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
            Text("플레이리스트에 추가하기")
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
                            isLocked: viewModel.isMusic(music, includedIn: playlist)
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
            viewModel.addMusic(
                music,
                toPlaylistsWithIds: selectedPlaylistIDs,
                from: playlists
            )
            dismiss()
        } label: {
            Text("추가하기")
                .font(.system(size: 18, weight: .medium))
        }
        .buttonStyle(CustomButtonStyle())
        .disabled(selectedPlaylistIDs.isEmpty)
        .opacity(selectedPlaylistIDs.isEmpty ? 0.4 : 1)
    }

    private func isChecked(_ playlist: MusicPlaylist) -> Bool {
        viewModel.isMusic(music, includedIn: playlist) || selectedPlaylistIDs.contains(playlist.id)
    }

    private func toggleSelection(for playlist: MusicPlaylist) {
        guard !viewModel.isMusic(music, includedIn: playlist) else { return }

        if selectedPlaylistIDs.contains(playlist.id) {
            selectedPlaylistIDs.remove(playlist.id)
        } else {
            selectedPlaylistIDs.insert(playlist.id)
        }
    }
}
