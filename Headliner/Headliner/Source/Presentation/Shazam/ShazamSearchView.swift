import MusicKit
import ShazamKit
import SwiftUI

struct ShazamSearchView: View {
    @EnvironmentObject var container: DIContainer
    @Environment(\.modelContext) private var context
    @Environment(AudioPreviewManager.self) private var audioManager
    
    @StateObject var viewModel: ShazamViewModel
    @State private var previousScrollOffset: CGFloat = 0
    
    @Binding var isScrolled: Bool
    
    private let scrollThreshold: CGFloat = 20
    
    var body: some View {
        NavigationStack(path: $container.pathModel.paths) {
            VStack(spacing: 0) {
                SearchBarView(text: $viewModel.query)
                
                if !viewModel.query.isEmpty {
                    searchResultListView
                } else {
                    shazamDefaultView
                }
            }
            .toolbarBackgroundVisibility(.hidden, for: .tabBar)
            .navigationDestination(for: PathType.self) { type in
                switch type {
                case .loading:
                    ShazamLoadingView(viewModel: viewModel)
                case .result(let item):
                    MediaItemView(
                        viewModel: viewModel,
                        mediaItem: item.mediaItem,
                        result: item
                    )
                }
            }
            .background {
                backgroundView.ignoresSafeArea(.all)
            }
        }
        .onChange(of: viewModel.query) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isScrolled = false
            }
            previousScrollOffset = 0
        }
    }
    
    private var searchResultListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.results) { song in
                    SearchMusicRowView(
                        title: song.title,
                        artistName: song.artistName,
                        artworkURL: song.artworkURL,
                        isPlaying: audioManager.currentSong?.id == song.id
                            && audioManager.isPlaying,
                        isAdded: viewModel.addedSongIDs.contains(song.id),
                        onPlay: {
                            audioManager.play(song: song)
                        },
                        onAdd: {
                            Task {
                                await viewModel.addSongFromSearch(
                                    song: song,
                                    context: context
                                )
                            }
                        }
                    )
                }
            }
            .scrollTargetLayout()
        }
        .onAppear {
            viewModel.loadAddedSongIDs(context: context)
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldValue, newValue in
            let delta = newValue - previousScrollOffset
            
            if delta > scrollThreshold {
                // 아래로 스크롤 (content가 위로 올라감)
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = true
                }
            } else if delta < -scrollThreshold {
                // 위로 스크롤 (content가 아래로 내려감)
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = false
                }
            }
            
            previousScrollOffset = newValue
        }
    }
    
    private var shazamDefaultView: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(spacing: 24) {
                shazamButton
                Text("Sing Cue 하려면 탭하세요")
                    .font(.pretendardBold20)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 100)
            
            Spacer()
        }
    }
    
    private var shazamButton: some View {
        Button {
            if !viewModel.isListening() {
                viewModel.start()
            }
        } label: {
            Image(.shazamButton)
                .resizable()
                .frame(width: 220, height: 220)
                .symbolEffect(.pulse, isActive: viewModel.isListening())
                .foregroundColor(viewModel.isListening() ? .orange : .blue)
        }
        .disabled(viewModel.isListening())
        .alert("마이크 권한이 없습니다.", isPresented: $viewModel.showPermissionAlert) {
            Button("앱 설정") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("Sing Cue 기능을 사용하려면 앱의 마이크 권한을 허용해주세요.")
        }
    }
    
    private var backgroundView: some View {
        LinearGradient.backgroundGradient.ignoresSafeArea(.all)
    }
}

struct SearchBarView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField(
                "",
                text: $text,
                prompt: Text("노래를 검색하세요").foregroundStyle(.white.opacity(0.6))
            )
            .focused($isFocused)
            .textFieldStyle(CustomTextFieldStyle())
            .padding(.leading, 20)
            
            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.trailing, 20)
            } else {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 20)
            }
        }
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .overlay {
            RoundedRectangle(cornerRadius: 40).strokeBorder(Color.white.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 25)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
