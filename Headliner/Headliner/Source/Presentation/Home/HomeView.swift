import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DIContainer

    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false

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
        .tint(.white) // 선택된 아이콘 색상만 설정
        .tabBarMinimizeBehavior(.onScrollDown)
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
            if !isKeyboardVisible && container.pathModel.paths.isEmpty {
                CustomTabBar(
                    isScrolled: $isScrolled,
                    showsSearchBar: true,
                    activeTab: $container.activeTab
                )
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
                .background(.clear)
            }
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
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
