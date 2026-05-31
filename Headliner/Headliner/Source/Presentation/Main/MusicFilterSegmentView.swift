//
//  MusicFilterSegmentView.swift
//  Headliner
//
//  뮤직 리스트 상단의 "전체 / 플레이리스트" 필터 세그먼트 (UI)
//

import SwiftUI

// MARK: - Filter Type
enum MusicFilterType: String, CaseIterable, Identifiable {
    case all = "전체"
    case playlist = "플레이리스트"

    var id: String { rawValue }
}

// MARK: - Segment View
struct MusicFilterSegmentView: View {
    @Binding var selection: MusicFilterType

    var body: some View {
        HStack(spacing: 10) {
            ForEach(MusicFilterType.allCases) { type in
                pill(for: type)
            }
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 4)
    }

    private func pill(for type: MusicFilterType) -> some View {
        let isSelected = selection == type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = type
            }
        } label: {
            Text(type.rawValue)
                .font(.pretendardBold16)
                .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.6))
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 120.0 / 255.0).opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isSelected ? Color.white : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
