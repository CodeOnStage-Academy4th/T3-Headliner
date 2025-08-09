//
//  ShazamSearchView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI
import ShazamKit

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
    
    @State var keyword: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient.backgroundGradient.ignoresSafeArea(.all)
            VStack(spacing: 24) {
                TextField("Search", text: $keyword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .padding(.horizontal, 25)
                
                shazamButton
                Text("샤잠하려면 탭하세요")
                    .font(.pretendardBold20)
                    .foregroundStyle(.white.opacity(0.6))
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

