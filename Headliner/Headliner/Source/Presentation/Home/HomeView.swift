import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DIContainer

    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @State private var audioManager = AudioPreviewManager()

    var body: some View {
        if #available(iOS 26, *) {
            ios26TabView
        } else {
            legacyTabView
        }
    }

    @available(iOS 26, *)
    private var ios26TabView: some View {
        TabView(selection: $container.activeTab) {
            Tab("", image: "threeLine", value: .main) {
                MainListView(
                    viewModel: .init(container: container),
                    isScrolled: $isScrolled
                )
            }

            Tab("", image: "mag", value: .search) {
                ShazamSearchView(
                    viewModel: .init(container: container),
                    isScrolled: $isScrolled
                )
            }
        }
        .tint(.white)
        .tabBarMinimizeBehavior(.onScrollDown)
        .overlay(alignment: .bottom) {
            if audioManager.currentSong != nil {
                MiniPlayerView()
                    .padding(.bottom, 100)
            }
        }
        .environment(audioManager)
        .environmentObject(container)
        .onAppear {
            container.setModelContext(modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - iOS 26 미만

    private var legacyTabView: some View {
        TabView(selection: $container.activeTab) {
            MainListView(
                viewModel: .init(container: container),
                isScrolled: $isScrolled
            )
            .tag(TabItem.main)

            ShazamSearchView(
                viewModel: .init(container: container),
                isScrolled: $isScrolled
            )
            .tag(TabItem.search)
        }
        .tabViewStyle(.automatic)
        .environmentObject(container)
        .onAppear {
            container.setModelContext(modelContext)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 12) {
                // 미니 플레이어 (탭바 위에 배치)
                if audioManager.currentSong != nil {
                    MiniPlayerView()
                }

                if !isKeyboardVisible && container.pathModel.paths.isEmpty {
                    CustomTabBar(
                        isScrolled: $isScrolled,
                        showsSearchBar: true,
                        activeTab: $container.activeTab
                    )
                    .padding(.horizontal, 25)
                    .background(.clear)
                }
            }
            .padding(.bottom, 30)
        }
        .environment(audioManager)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
