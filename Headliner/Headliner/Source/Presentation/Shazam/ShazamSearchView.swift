import SwiftUI
import ShazamKit
import MusicKit

struct MediaRoute: Hashable {
    let title: String
    let artist: String
    let artworkURL: URL?
    let mediaItem: SHMediaItem?
}

struct ShazamSearchView: View {
    @EnvironmentObject var pathModel: PathModel
    @StateObject private var viewModel = ShazamViewModel()
    //    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient.backgroundGradient.ignoresSafeArea(.all)
                VStack(spacing: 0) {
                    Spacer().frame(height: 10)
                    
                    SearchBarView(text: $viewModel.query)
                        .padding(.horizontal, 25)
                        .padding(.top)

                    if !viewModel.query.isEmpty {
                        List(viewModel.results) { song in
                            MusicRowView(
                                title: song.title,
                                artistName: song.artistName,
                                artworkURL: song.artworkURL,
                                previewURL: song.previewURL
                            )
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    } else {
                        Spacer()
                        
                        shazamButton
                        
                        Text("샤잠하려면 탭하세요")
                            .font(.pretendardBold20)
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Spacer()
                    }
                }
            }
        }
        .task {
            await viewModel.prepare()
        }
        .onChange(of: viewModel.currentItem) { _, item in
            if let item {
                let route = MediaRoute(
                    title: item.title ?? "",
                    artist: item.artist ?? "",
                    artworkURL: item.artworkURL,
                    mediaItem: item
                )
                pathModel.paths.append(.result(route))
            }
            .onChange(of: viewModel.currentItem) { _, item in
                if let item {
                    let route = MediaRoute(
                        title: item.title ?? "",
                        artist: item.artist ?? "",
                        artworkURL: item.artworkURL,
                        mediaItem: item
                    )
                    path.append(route)
                }
            }
            .navigationDestination(for: MediaRoute.self) { route in
                if let mediaItem = route.mediaItem {
                    MediaItemView(mediaItem: mediaItem)
                } else {
                    Text("MediaItem을 찾을 수 없습니다")
                }
            }
        }
    }
    
    private var shazamButton: some View {
        Button{
            if !viewModel.isListening {
                viewModel.start()
                pathModel.paths.append(.loading)
            }
        } label: {
            Image(systemName: "shazam.logo.fill")
                .resizable()
                .frame(width: 52, height: 52)
                .symbolEffect(.pulse, isActive: viewModel.isListening)
                .foregroundColor(viewModel.isListening ? .orange : .blue)
        }
        .disabled(viewModel.isListening)
    }
}

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("검색할 노래를 입력하세요...", text: $text)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
}
