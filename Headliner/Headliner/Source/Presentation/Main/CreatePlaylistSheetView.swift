//
//  CreatePlaylistSheetView.swift
//  Headliner
//
//  새 플레이리스트 생성 시트
//

import SwiftUI

struct CreatePlaylistSheetView: View {
    let viewModel: PlaylistViewModel
    let initialMusic: PlaylistMusic?
    let onCreate: ((MusicPlaylist) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFocused: Bool
    @State private var title: String

    init(
        defaultTitle: String,
        viewModel: PlaylistViewModel,
        initialMusic: PlaylistMusic? = nil,
        onCreate: ((MusicPlaylist) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.initialMusic = initialMusic
        self.onCreate = onCreate
        _title = State(initialValue: defaultTitle)
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header

            Spacer(minLength: 120)

            Text("플레이리스트 이름을 지정하세요")
                .font(.pretendardBold20)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Spacer(minLength: 76)

            titleField

            Spacer(minLength: 40)

            addButton

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(.ultraThinMaterial)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isTitleFocused = true
            }
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
            Text("새 플레이리스트")
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

    // MARK: - Title Field
    private var titleField: some View {
        VStack(spacing: 8) {
            TextField("", text: $title)
                .font(.custom("Pretendard-Bold", size: 30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isTitleFocused)
                .submitLabel(.done)
                .onSubmit {
                    createPlaylist()
                }

            Rectangle()
                .fill(Color.inputDivider)
                .frame(width: 212, height: 1)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Add Button
    private var addButton: some View {
        Button {
            createPlaylist()
        } label: {
            Text("추가하기")
                .font(.system(size: 18, weight: .medium))
        }
        .buttonStyle(CustomButtonStyle())
        .disabled(!isAddEnabled)
        .opacity(isAddEnabled ? 1 : 0.4)
    }

    private var isAddEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createPlaylist() {
        guard let playlist = viewModel.createPlaylist(
            title: title,
            initialMusic: initialMusic
        ) else { return }

        onCreate?(playlist)
        dismiss()
    }
}
