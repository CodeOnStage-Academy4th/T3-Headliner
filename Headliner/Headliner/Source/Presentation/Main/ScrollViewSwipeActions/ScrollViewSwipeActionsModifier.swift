//
//  ScrollViewSwipeActionsModifier.swift
//  Headliner
//
//  Created by Subeen on 8/30/25.
//

import SwiftUI

struct ScrollViewSwipeActionsModifier: ViewModifier {
    
    @State private var size: CGSize = .init(width: 1, height: 1)
    
    func body(content: Content) -> some View {
        List {
            LazyVStack {
                content
            }
            .frame(height: 90)
            .readSize { size in
                self.size = size
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .frame(height: size.height)
        .contentMargins(.vertical, EdgeInsets(), for: .scrollContent)
    }
}

extension View {
    func enableScrollViewSwipeActions() -> some View {
        self.modifier(ScrollViewSwipeActionsModifier())
    }
}
