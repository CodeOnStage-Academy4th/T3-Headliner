//
//  HomeView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ShazamViewModel()
    
    @State private var activeTab: TabItem = .main
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var bottomPadding: CGFloat = 0
    @EnvironmentObject var pathModel: PathModel
    
    var body: some View {
        NavigationStack(path: $pathModel.paths){
            ZStack(alignment: .bottom) {
                // 배경 이미지
                Image("EmptyBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // 메인 콘텐츠
                TabView(selection: $activeTab) {
                    MainListView(
                        playList: viewModel.playList,
                        isScrolled: $isScrolled,
                        scrollOffset: $scrollOffset
                    )
                    .background(Color.clear)
                    .tag(TabItem.main)
                    
                    ShazamSearchView()
                        .background(Color.clear)
                        .tag(TabItem.search)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .overlay(alignment: .bottom) {
                CustomTabBar(
                    isScrolled: isScrolled,
                    showsSearchBar: true,
                    activeTab: $activeTab
                ) { isExpanded in
                    print("Search bar expanded: \(isExpanded)")
                } onSearchTextChanged: { searchText in
                    print("Search text: \(searchText)")
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 70)
                .background(.clear)
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

//#Preview {
//    HomeView()
//}
