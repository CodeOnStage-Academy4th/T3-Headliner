//
//  HomeView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var activeTab: TabItem = .resents
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $activeTab) {
                MainListView(isScrolled: $isScrolled, scrollOffset: $scrollOffset)
                    .tag(TabItem.resents)
                ShazamSearchView()
                    .tag(TabItem.shared)
                
                // 스크롤 감지를 위한 background GeometryReader
                    
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            
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
