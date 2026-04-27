import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DIContainer

    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolled: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @State private var audioManager = AudioPreviewManager()

    var body: some View {
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
}

// MARK: - ScrollOffsetPreferenceKey

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
