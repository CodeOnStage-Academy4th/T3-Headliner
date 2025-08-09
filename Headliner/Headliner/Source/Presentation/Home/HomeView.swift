//
//  HomeView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var activeTab: TabItem = .main
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @EnvironmentObject var pathModel: PathModel
    
    var body: some View {
        NavigationStack(path: $pathModel.paths){
            ZStack(alignment: .bottom) {
                Image("EmptyBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                TabView(selection: $activeTab) {
                    MainListView(playList: viewModel.playList,
                                 isScrolled: $isScrolled,
                                 scrollOffset: $scrollOffset)
                        .background(Color.clear)
                        .tag(TabItem.resents)

                    ShazamSearchView()
                        .background(Color.clear)
                        .tag(TabItem.shared)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
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
                .padding(.horizontal, 25)
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 + 4)
                
            }
            .navigationDestination(for: PathType.self) { type in
                switch type {
                case .loading:
                    ShazamLoadingView()
                case .result(let item):
                    if let item = item.mediaItem {
                        MediaItemView(mediaItem: item)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        // PathModel을 통해 루트로 돌아가기
                                        pathModel.paths.removeAll()
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 20, weight: .medium))
                                    }
                                }
                            }
                    }
                }
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
