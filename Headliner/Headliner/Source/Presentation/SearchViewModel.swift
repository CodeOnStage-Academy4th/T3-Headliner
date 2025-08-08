import Foundation
import MusicKit
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var errorMessage: String?
    @Published var results: [Music] = []
    @Published var playList: [PlaylistMusic] = []
    
    var karaokeResponse: SongResponse?
    var songService = SongService()

    private var cancellables = Set<AnyCancellable>()
    private let service: MusicServicing

    init(service: MusicServicing = MusicManager()) {
        self.service = service
        bindSearchTerm()

        Task { _ = await service.requestAuthorization() }
    }

    private func bindSearchTerm() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if term.count >= 2 {
                    Task {
                        await self.search(with: term)
                    }
                } else {
                    self.results = []
                }
            }
        }
            .store(in: &cancellables)
    }

    @MainActor
    func search(with term: String) async {
        if term.isEmpty {
            results = []
        } else {
            errorMessage = nil

            do {
                let searchResults = try await service.searchSongs(
                    term: term,
                    limit: 25
                )
                results = searchResults.sorted {
                    $0.title.localizedStandardCompare($1.title) == .orderedAscending
                }
            } catch {
                results = []
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func addMusic(song: Music) async {
        await MainActor.run {
            let newPlaylistSong = PlaylistMusic(
                id: song.id,
                originalSong: song,
                karaokeNumber: "000000"
            )
            
            self.playList.append(newPlaylistSong)
            
            print("Playlist에 추가됨: \(newPlaylistSong.originalSong.title) - 노래방 번호: \(newPlaylistSong.karaokeNumber ?? "없음")")
            print("PlayList: \(playList)")
        }
    }
    
    @MainActor
    func getKaraokeNumber(
        title: String,
        singer: String,
        brand: String,
        limit: String,
        page: String
    ) async {
        do {
            let newResponse = try await songService.searchBoth(
                title: title,
                singer: singer,
                brand: brand,
                limit: limit,
                page: page
            )
            self.karaokeResponse = newResponse
        } catch {
            // Log.network("Result VM - searchBoth error", error)
        }
    }
}
