//
//  SearchView.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import SwiftUI

struct ResultView: View {
    
    @State var viewModel: ResultViewModel
    @State var title: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("제목을 입력하세요.", text: $title)
                Button {
                    Task {
                        await viewModel.searchSongExact(title: title, brand: "", limit: "10", page: "3")
                    }
                    
                } label: {
                    Text("검색")
                }
            }
            
            ForEach(viewModel.songResponse?.data ?? []) { song in
                HStack {
                    Text("\(String(describing: song.title!))")
                    Text("\(String(describing: song.no!))")
                }
                .foregroundStyle(Color.black)
            }
        }
    }
}

#Preview {
    ResultView(viewModel: .init())
}
