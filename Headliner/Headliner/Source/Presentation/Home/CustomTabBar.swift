//
//  CustomTabBar.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    
    case resents = "Recents"
    case shared = "Shared"
//    case browse = "Browse"
    
    var symbol: String {
        switch self {
        case .resents:
            return "clock.fill"
        case .shared:
            return "folder.fill.badge.person.crop"
//        case .browse:
//            return "folder.fill"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

struct CustomTabBar: View {
    
    var isScrolled: Bool
    var showsSearchBar: Bool = false
    @Binding var activeTab: TabItem
    var onSearchBarExpanded: (Bool) -> ()
    var onSearchTextChanged: (String) -> ()
    /// View Properties
    @GestureState private var isActive: Bool = false
    @State private var isInitialOffsetSet: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat?
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let tabs = TabItem.allCases.prefix(showsSearchBar ? 4 : 5)
            let tabItemWidth = max(min(size.width / CGFloat(tabs.count + (showsSearchBar ? 1 : 0)), 90), 60)
            let tabItemHeight: CGFloat = 56
            
            ZStack {
                if isInitialOffsetSet {
                    HStack(spacing: 12) {
                        let tabLayout = isScrolled ? AnyLayout(ZStackLayout()) : AnyLayout(HStackLayout(spacing: 0))
                        tabLayout {
                            ForEach(tabs, id: \.rawValue) { tab in
                                TabItemView(tab, width: tabItemWidth, height: tabItemHeight)
                                    .opacity(isScrolled ? (activeTab == tab ? 1 : 0) : 1)
                            }
                        }
                        /// Draggable Active Tab
                        .background(alignment: .leading) {
                            ZStack {
                                Capsule(style: .continuous)
                                
                                    .stroke(.gray.opacity(0.25), lineWidth: 3)
                                    .opacity(isActive ? 1 : 0)
                                
                                
                                Capsule(style: .continuous)
                                    
                                    .fill(Color.white.opacity(0.2))
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                    .opacity(isScrolled ? 0 : 1)
                            }
                            .compositingGroup()
                            
                            .frame(width: tabItemWidth, height: tabItemHeight)
                            /// Scaling when drag gesture becomes active
                            .scaleEffect(isActive ? 1.3 : 1)
                            .offset(x: dragOffset)
                        }
                        /// centering tab bar
                        .padding(3)
                        .background(TabBarBackground())
                        
                        if isScrolled {
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                guard !isInitialOffsetSet else { return }
                dragOffset = CGFloat(activeTab.index) * tabItemWidth
                isInitialOffsetSet = true
            }
            
        }
        .frame(height: 56)
        .padding(.horizontal, 25)
        /// Animations (Custom)
        .animation(.bouncy, value: dragOffset)
        .animation(.bouncy, value: isActive)
        .animation(.bouncy, value: activeTab)
        // TODO: effect
//        .scaleEffect(isScrolled ? 0.8 : 1.0)
    }
    
    /// Tab Item View
    @ViewBuilder
    private func TabItemView(_ tab: TabItem, width: CGFloat, height: CGFloat) -> some View {
        
        let tabs = TabItem.allCases.prefix(showsSearchBar ? 4 : 5)
        let tabCount = tabs.count - 1
        
        VStack(spacing: 6) {
            Image(systemName: tab.symbol)
                .font(.title2)
                .symbolVariant(.fill)
        }
        .foregroundStyle(activeTab == tab ? Color.white : Color.white.opacity(0.2))
        .frame(width: width, height: height)
        .contentShape(.capsule)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isActive, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    let xOffset = value.translation.width
                    if let lastDragOffset {
                        let newDragOffset = xOffset + lastDragOffset
                        dragOffset = max(min(newDragOffset, CGFloat(tabCount) * width), 0)
                    } else {
                        lastDragOffset = dragOffset
                    }
                })
                .onEnded({ value in
                    lastDragOffset = nil
                    
                    /// identifying the landing index
                    let landingIndex = Int((dragOffset / width).rounded())
                    
                    /// safe - check
                    if tabs.indices.contains(landingIndex) {
                        dragOffset = CGFloat(landingIndex) * width
                        activeTab = tabs[landingIndex]
                    }
                })
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    activeTab = tab
                    dragOffset = CGFloat(tab.index) * width
                }
        )
    }
    
    /// Tab Bar Background View
    @ViewBuilder
    private func TabBarBackground() -> some View {
        if !isScrolled {
            ZStack {
//                Capsule(style: .continuous)
//                    .stroke(.gray.opacity(0.25), lineWidth: 0.25)
                
                Capsule(style: .continuous)
                    .fill(LinearGradient.componentGradient)
                    .strokeBorder(Color.white.opacity(0.2))
//
//                Capsule(style: .continuous)
//                    .fill(.ultraThinMaterial)
                
            }
        } else {
            ZStack {
                Circle()
                    .fill(LinearGradient.componentGradient)
                    .strokeBorder(Color.white.opacity(0.2))
            }
        }
    }
}

#Preview {
    HomeView()
}
