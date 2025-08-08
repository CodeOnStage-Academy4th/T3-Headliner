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
    @Binding var isScrolled: Bool
    @Binding var scrollOffset: CGFloat
    
    var body: some View {
        ZStack {
            LinearGradient.backgroundGradient
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
            
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                scrollOffset = geo.frame(in: .global).minY
                                print("Initial scroll offset set: \(scrollOffset)")
                            }
                            .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                let offset = newValue
                                print("Current scroll offset: \(offset), Initial: \(scrollOffset)")
                                
                                // 초기 위치에서 50포인트 이상 위로 올라갔을 때 (스크롤 다운)
                                let shouldBeScrolled = offset < scrollOffset - 50
                                
                                if shouldBeScrolled != isScrolled {
                                    print("TabBar scale changing: \(isScrolled) -> \(shouldBeScrolled)")
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isScrolled = shouldBeScrolled
                                    }
                                }
                            }
                    }
                )
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
    MainListView(isScrolled: .constant(false), scrollOffset: .constant(0))
}
