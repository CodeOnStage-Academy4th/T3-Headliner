//
//  MediaItemButtonsView.swift
//  Headliner
//
//  Created by Henry on 8/19/25.
//

import SwiftUI

struct MediaItemButtonsView: View {
    let showsRetryButton: Bool
    let onRetry: () -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("추가하기")
                        .font(.pretendardSemiBold18)
                }
            }
            .buttonStyle(CustomButtonStyle())
            
            if showsRetryButton {
                Button(action: onRetry) {
                    ZStack {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("추가하기")
                        }
                        .font(.pretendardSemiBold18)
                        .opacity(0) // 추가하기 버튼 크기와 맞추기 위함
                        
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("재시도")
                        }
                        .font(.pretendardSemiBold18)
                    }
                }
                .buttonStyle(RetryButtonStyle())
            }
        }
    }
}
