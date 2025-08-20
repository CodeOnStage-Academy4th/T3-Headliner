import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    @State var playlistDataManager = PlaylistDataManager()
//    @State private var shazamViewModel = ShazamViewModel()
    
    @State private var activeTab: TabItem = .main
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
//    @EnvironmentObject var pathModel: PathModel
    
    private var shouldShowSearchBackground: Bool {
        activeTab == .search
    }
    
    var body: some View {
        NavigationStack(path: container.pathModel.paths){
            ZStack(alignment: .bottom) {
                if activeTab == .main {
                    MainListView(
                        viewModel: .init(playlistDataManager: playlistDataManager, container: container),
                        isScrolled: $isScrolled,
                        scrollOffset: $scrollOffset
                    )
                    .background(Color.clear)
                } else {
//                    ShazamSearchView(viewModel: shazamViewModel)
                    ShazamSearchView(
                        viewModel: .init(playlistDataManager: playlistDataManager, pathModel: pathModel)
                    )
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
                case .result(let item):
                    if let mediaItem = item.mediaItem {
//                        MediaItemView(viewModel: viewModel, mediaItem: <#T##SHMediaItem#>, showsRetryButton: <#T##Bool#>)
                        MediaItemView(mediaItem: mediaItem, showsRetryButton: item.showsRetryButton) {
                            <#code#>
                        } onAddMusic: { _ in
                            
                        }

                        MediaItemView(
                            viewModel: shazamViewModel,
                            mediaItem: mediaItem,
                            showsRetryButton: item.showsRetryButton
                        )
                        .navigationBarBackButtonHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        pathModel.removeAll()
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
//        .environmentObject(viewModel)
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
