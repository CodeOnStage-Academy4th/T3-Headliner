import MusicKit
import ShazamKit
import SwiftUI

struct ShazamSearchView: View {
    @EnvironmentObject var container: DIContainer
    
    @StateObject var viewModel: ShazamViewModel
    @State private var scrolledID: MusicSearchResult.ID?
    @State private var scrollPostion: ScrollPosition = .init(idType: MusicSearchResult.ID.self)
    
    @Binding var isScrolled: Bool
    
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
                    if let mediaItem = item.mediaItem {
                        MediaItemView(
                            viewModel: viewModel,
                            mediaItem: mediaItem,
                            showsRetryButton: item.showsRetryButton
                        )
                    }
                }
            }
            .background {
                backgroundView.ignoresSafeArea(.all)
            }
        }
        .task {
            await container.managers.shazamManager.prepare()
        }
        .onChange(of: viewModel.query) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isScrolled = false
            }
        }
        .onChange(of: viewModel.results) { _, newValue in
            if let firstResult = newValue.first {
                scrolledID = firstResult.id
            }
        }
    }
    
    private var searchResultListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.results) { song in
                    Button {
                        viewModel.handleMusicSelection(song: song)
                    } label: {
                        MusicRowView(
                            title: song.title,
                            artistName: song.artistName,
                            artworkURL: song.artworkURL,
                            previewURL: song.previewURL,
                            karaokeNumber: nil
                        )
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledID)
        .onChange(of: scrolledID) { _, _ in
            guard let id = scrolledID else { return }
            
            if id != viewModel.results.first?.id {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScrolled = false
                }
            }
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
