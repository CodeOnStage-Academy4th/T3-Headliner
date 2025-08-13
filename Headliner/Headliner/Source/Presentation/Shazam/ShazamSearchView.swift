import SwiftUI
import ShazamKit
import MusicKit



struct ShazamSearchView: View {
    @EnvironmentObject var pathModel: PathModel
    @StateObject private var viewModel = ShazamViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.backgroundGradient
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // 상단 고정 SearchBar
                SearchBarView(text: $viewModel.query)
                    .padding(.horizontal, 25)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                // 스크롤 가능한 컨텐츠 영역
                if !viewModel.query.isEmpty {
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
                    }
                } else {
                    VStack {
                        Spacer(minLength: 10) // 최소 여백 보장
                        
                        VStack(spacing: 24) {
                            shazamButton
                            Text("Sing Cue 하려면 탭하세요")
                                .font(.pretendardBold20)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
        .task {
            await viewModel.prepare()
        }
        .onChange(of: viewModel.navigationRoute) { _, route in
            if let route = route {
                pathModel.paths.append(route)
            }
        }
    }
    
    private var shazamButton: some View {
        Button{
            if !viewModel.isListening {
                viewModel.start()
            }
        } label: {
            Image(.shazamButton)
                .resizable()
                .frame(width: 220, height: 220)
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
            TextField(
                "",
                text: $text,
                prompt: Text("노래를 검색하세요").foregroundStyle(.white.opacity(0.6))
            )
            .textFieldStyle(CustomTextFieldStyle())
            .padding(.leading, 20)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
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
    }
}

