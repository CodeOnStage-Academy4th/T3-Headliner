//
//  EmptyResultView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct EmptyResultView: View {
    var body: some View {
        ZStack {
            LinearGradient.backgroundGradient.ignoresSafeArea(.all)
            VStack(spacing: 47) {
                
                contentView
                
                Button {
                    // TODO: 재시도
                } label: {
                    Text("재시도")
                }
                .buttonStyle(CustomButtonStyle())
            }
        }
    }
    
    var contentView: some View {
        VStack(spacing: 12) {
            Text("결과 없음")
                .font(Font.pretendardBold20)
            Text("일치하는 컨텐츠를 찾을 수 없습니다.")
        }
        .foregroundStyle(Color.white)
    }
}

#Preview {
    EmptyResultView()
}
