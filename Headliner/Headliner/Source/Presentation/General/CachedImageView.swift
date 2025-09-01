//
//  CachedImageView.swift
//  Headliner
//
//  Created by Henry on 9/1/25.
//

import SwiftUI

struct CachedImageView: View {
    @State private var image: UIImage?
    @State private var isLoading = false
    let url: URL?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .onAppear {
            Task {
                await loadImage()
            }
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url = url else { return }

        // 1. 캐시에서 먼저 확인
        if let cachedImage = ImageCache.shared.getImage(from: url) {
            self.image = cachedImage
            return 
        }

        // 2. 캐시에 없으면 네트워크에서 다운로드
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloadedImage = UIImage(data: data) else {
                isLoading = false
                return
            }
            
            ImageCache.shared.setImage(downloadedImage, for: url)
            self.image = downloadedImage
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
