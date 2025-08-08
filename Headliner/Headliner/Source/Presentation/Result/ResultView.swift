//
//  SearchView.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import SwiftUI

struct ResultView: View {
    
    @State var viewModel: ResultViewModel
    @State var title: String = "좋은날"
    @State var singer: String = "IU"
    
    var body: some View {
        VStack {
            HStack {
                TextField("제목을 입력하세요.", text: $title)
                Button {
                    Task {
                        await viewModel.searchBoth(
                            title: title,
                            singer: singer,
                            brand: "tj",
                            limit: "10",
                            page: "1"
                        )
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
