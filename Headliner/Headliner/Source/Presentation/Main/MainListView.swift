//
//  MainListView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI

struct MainListView: View {
    // TODO: 실제 데이터 연결 필요
    let dummy: [Music] = (0..<10).map { i in
        Music(id: "\(i)", title: "어제보다 슬픈 오늘", artistName: "마크툽",
              artworkURL: nil, previewURL: nil)
    }
    
    let viewTitle: String = "나의 뮤직 리스트"
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .blue.opacity(0.6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                titleView
                scrollView
            }
        }
    }
    
    var titleView: some View {
        Text(viewTitle)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
            .padding(.top, 12)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(dummy) { t in
                    MusicRowView(title: t.title,
                                 artistName: t.artistName,
                                 artworkURL: t.artworkURL,
                                 previewURL: t.previewURL)
                }
            }
        }
    }
}



#Preview {
    MainListView()
}
