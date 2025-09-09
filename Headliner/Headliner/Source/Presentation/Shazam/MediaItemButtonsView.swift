//
//  MediaItemButtonsView.swift
//  Headliner
//
//  Created by Henry on 8/19/25.
//

import SwiftUI

struct MediaItemButtonsView: View {
    let resultType: SearchStatusType
    let onRetry: () -> Void
    let onAdd: () -> Void

    var body: some View {
        switch resultType {
        case .complete:
            completionButton

        case .completeShazam:
            completionShazamButton

        case .failure:
            failureButton
        }
    }

    func buttonView(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.pretendardSemiBold18)
        }
    }

    var completionButton: some View {
        Button {
            onAdd()
        } label: {
            buttonView(icon: "plus", title: "추가하기")
        }
        .buttonStyle(CustomButtonStyle())
    }

    var completionShazamButton: some View {
        VStack(spacing: 12) {
            Button {
                onAdd()
            } label: {
                buttonView(icon: "plus", title: "추가하기")
            }
            .buttonStyle(CustomButtonStyle())

            Button {
                onRetry()
            } label: {
                buttonView(icon: "arrow.counterclockwise", title: "재시도")
            }
            .buttonStyle(RetryButtonStyle())
        }
    }

    var failureButton: some View {
        Button {
            onRetry()
        } label: {
            buttonView(icon: "arrow.counterclockwise", title: "재시도")
        }
        .buttonStyle(RetryButtonStyle())
    }
}

#Preview {
    MediaItemButtonsView(resultType: .completeShazam, onRetry: {}, onAdd: {})
}
