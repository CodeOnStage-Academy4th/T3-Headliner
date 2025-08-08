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
                .id("top")
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                scrollOffset = geo.frame(in: .global).minY
                            }
                            .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                let offset = newValue
                                print("Real-time scroll offset: \(offset)")
                                
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
