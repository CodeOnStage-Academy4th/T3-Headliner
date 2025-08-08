//
//  HomeView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var activeTab: TabItem = .shared
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<20) { i in
                        Text("Item \(i)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding()
                // 스크롤 감지를 위한 background GeometryReader
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scrollView")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation(.easeInOut(duration: 0.25)) {
                    scrollOffset = value
                    // 스크롤이 50포인트 이상 내려갔을 때 축소
                    isScrolled = value < -50
                }
            }
            
            CustomTabBar(
                isScrolled: isScrolled,
                showsSearchBar: true,
                activeTab: $activeTab
            ) { isExpanded in
                // 검색바 확장/축소 처리
                print("Search bar expanded: \(isExpanded)")
            } onSearchTextChanged: { searchText in
                // 검색 텍스트 변경 처리
                print("Search text: \(searchText)")
            }
        }
    }
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView()
}
