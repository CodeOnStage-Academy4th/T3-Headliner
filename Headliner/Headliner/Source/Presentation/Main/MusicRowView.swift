//
//  MusicRowView.swift
//  Headliner
//
//  Created by Henry on 8/9/25.
//

import SwiftUI

struct MusicRowView: View {
    let title: String
    let artistName: String
    let artworkURL: URL?
    let previewURL: URL?

    var body: some View {
        ZStack {
            Color.clear
            
            HStack(spacing: 20) {
                AsyncImage(url: artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                         .scaledToFill()
                case .failure:
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white.opacity(0.8))
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title).foregroundStyle(.white).lineLimit(1).font(.pretendardSemiBold18)
                            Text(artistName).foregroundStyle(.gray).lineLimit(1).font(.pretendardSemiBold14)
                            
                        }
                        Spacer()
                        Text("12345")
                            .font(.pretendardSemiBold16)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 10)
                    Divider()
                        .background(.gray)
                }
            }
            .background(Color.clear)
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
