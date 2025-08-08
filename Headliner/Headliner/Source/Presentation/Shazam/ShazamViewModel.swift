//
//  ShazamViewModel.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import Foundation
import ShazamKit

@MainActor
final class ShazamViewModel: ObservableObject {

    @Published var isListening: Bool = false
    @Published var currentItem: SHMediaItem?
    @Published var errorDescription: String?
    @Published var status: Status = .search

    var title: String { currentItem?.title ?? "" }
    var artist: String { currentItem?.artist ?? "" }
    var artworkURL: URL? { currentItem?.artworkURL }

    private let managedSession = SHManagedSession()
    private let library = SHLibrary.default

    init() {}
    
    enum Status {
        case search
        case loading
        case completed
    }

    func prepare() async {
        await managedSession.prepare()
    }

    func start() {
        guard isListening == false else { return }
        isListening = true
        currentItem = nil
        errorDescription = nil
        self.status = .loading

        Task { [weak self] in
            guard let self else { return }
            let result = await self.managedSession.result()
            await self.handle(result)
        }
    }

    func retry() { start() }

    func cancel() {
        managedSession.cancel()
        isListening = false
        status = .search
    }

    private func handle(_ result: SHSession.Result) async {
        managedSession.cancel()
        isListening = false

        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
                currentItem = item
                    status = .completed
            } else {
                currentItem = nil
            }
        case .noMatch:
            currentItem = nil
        case .error(let error, _):
            errorDescription = error.localizedDescription
            currentItem = nil
        }
    }
}
