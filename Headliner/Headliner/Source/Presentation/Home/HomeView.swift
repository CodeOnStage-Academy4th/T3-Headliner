import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DIContainer
    
    @State private var activeTab: TabItem = .main
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
    
    private var shouldShowSearchBackground: Bool {
        activeTab == .search
    }
    
    var body: some View {
        Group {
            if activeTab == .main {
                MainListView(
                    isScrolled: $isScrolled,
                    scrollOffset: $scrollOffset,
                    viewModel: .init(
                        container: container
                    )
                )
                .background(Color.clear)
            } else {
                ShazamSearchView(viewModel: .init(container: container))
                    .background(Color.clear)
            }
        }
        .environmentObject(container)
        .onAppear {
            container.setModelContext(modelContext)
        }
        .overlay(alignment: .bottom) {
            if !isKeyboardVisible && container.pathModel.paths.isEmpty {
                CustomTabBar(
                    isScrolled: $isScrolled,
                    showsSearchBar: true,
                    activeTab: $activeTab
                )
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
                .background(.clear)
                .onChange(of: isScrolled) { newValue in
                            print("HomeView - isScrolled changed:", newValue)
                        }
            }
        }
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
