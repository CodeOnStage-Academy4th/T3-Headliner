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
            dataContainer = try ModelContainer(for: Song.self, PlaylistMusic.self)
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
        }
    }
}
