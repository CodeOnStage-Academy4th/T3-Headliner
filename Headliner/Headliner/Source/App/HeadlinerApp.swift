//
//  HeadlinerApp.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import SwiftData
import SwiftUI

@main
struct HeadlinerApp: App {
    @StateObject var container = DIContainer(managers: Managers())

    let dataContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Song.self,
                PlaylistMusic.self,
                MusicPlaylist.self,
                MusicPlaylistItem.self
            ])

            let config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )

            dataContainer = try ModelContainer(
                for: schema,
                configurations: config
            )
        } catch {
            fatalError("\(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
//                .environmentObject(PathModel())
                .environmentObject(container)
                .modelContainer(dataContainer)
                .task {
                    await container.managers.musicManager.warmUp()
                }
        }
    }
}
