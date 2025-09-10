//
//  ShazamSearchFailView.swift
//  Headliner
//
//  Created by Henry on 9/10/25.
//

import SwiftUI

struct ShazamSearchFailView: View {
    let onRetry: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Image("EmptyResearch")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("결과 없음")
                    .font(.pretendardBold20)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text("일치하는 콘텐츠를 찾을 수 없습니다.")
                    .font(.pretendardSemiBold16)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                Button {
                    onRetry()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("재시도")
                            .font(.pretendardSemiBold18)
                    }
                }
                .foregroundStyle(Color.white)
                .frame(width: 160)
                .padding(.vertical, 21)
                .background(LinearGradient.componentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color(hex: "#FFD4FE66").opacity(0.4)))
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            LinearGradient.backgroundGradient.ignoresSafeArea(.all)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }
    }
}

#Preview {
    ShazamSearchFailView(onRetry: {}, onBack: {})
}
