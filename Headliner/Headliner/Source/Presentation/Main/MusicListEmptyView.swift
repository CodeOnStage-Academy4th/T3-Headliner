//
//  MusicListEmptyView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI

struct MusicListEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("EmptyMic")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)

            Text("아직 저장된 노래가 없어요")
                .font(.pretendardSemiBold18)
                .foregroundStyle(.white)

            Text("검색으로 나만의 노래 리스트를\n만들어보아요")
                .font(.pretendardSemiBold14)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MusicListEmptyView()
}
