//
//  HeadlinerApp.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import SwiftUI

@main
struct HeadlinerApp: App {
    
    @StateObject var container = DIContainer(managers: Managers())
    
    var body: some Scene {
        WindowGroup {
            HomeView()
//                .environmentObject(PathModel())
                .environmentObject(container)
        }
    }
}
