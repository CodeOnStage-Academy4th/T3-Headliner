//
//  HomeView.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var activeTab: TabItem = .shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundStyle(.clear)
            
            CustomTabBar(activeTab: $activeTab) { isExpanded in
                
            } onSearchTextChanged: { searchText in
                
            }

        }
    }
}

#Preview {
    HomeView()
}
