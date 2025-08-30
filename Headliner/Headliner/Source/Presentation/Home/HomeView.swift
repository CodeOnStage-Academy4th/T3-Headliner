import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DIContainer
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
    
    var body: some View {
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
