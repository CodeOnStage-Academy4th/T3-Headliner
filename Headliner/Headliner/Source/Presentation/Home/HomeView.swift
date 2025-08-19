import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ShazamViewModel()
    
    @State private var activeTab: TabItem = .main
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @EnvironmentObject var pathModel: PathModel
    
    private var shouldShowSearchBackground: Bool {
        activeTab == .search
    }
    
    var body: some View {
        NavigationStack(path: $pathModel.paths){
            ZStack(alignment: .bottom) {
                if activeTab == .main {
                    MainListView(
                        playList: viewModel.playList,
                        isScrolled: $isScrolled,
                        scrollOffset: $scrollOffset
                    )
                    .background(Color.clear)
                } else {
                    ShazamSearchView()
                        .background(Color.clear)
                }
            }
            .overlay(alignment: .bottom) {
                if !isKeyboardVisible {
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
                    .padding(.bottom, 30)
                    .background(.clear)
                }
            }
            .navigationDestination(for: PathType.self) { type in
                switch type {
                case .loading:
                    ShazamLoadingView()
                case .result(let route):
                    if let mediaItem = route.mediaItem {
                        MediaItemView(
                            mediaItem: mediaItem,
                            showsRetryButton: route.showsRetryButton
                        )
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
            .background {
                backgroundView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
        .environmentObject(viewModel)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if shouldShowSearchBackground {
            LinearGradient.backgroundGradient
        } else {
            Image("EmptyBackground")
                .resizable()
                .scaledToFill()
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
