//
//  CustomSwipeAction.swift
//  Headliner
//
//  Created by Subeen on 8/28/25.
//

import SwiftUI

struct SwipeAction: Identifiable {
    var id = UUID().uuidString
    var symbolImage: String
    var tint: Color
    var background: Color
    
    /// View Properties
    var font: Font = .title3
    var size: CGSize = .init(width: 45, height: 45)
    var shape: some Shape = .circle
    var action: (inout Bool) -> ()
}

/// Swipe Action Builder
/// Accepts a set of actions without any 'return' or 'commas' and returns it in a array format
@resultBuilder
struct SwipeActionsBuilder {
    static func buildBlock(_ components: SwipeAction...) -> [SwipeAction] {
        return components
    }
}

/// Customization Properties
struct ActionConfig {
    var leadingPadding: CGFloat = 0
    var trailingPadding: CGFloat = 10
    var spacing: CGFloat = 10
    var occupiesFullWidth: Bool = true
}

extension View {
    /// Custom View Modifier
    @ViewBuilder
    func swipeActions(config: ActionConfig = .init(), @SwipeActionsBuilder actions: () -> [SwipeAction]) -> some View {
        self
            .modifier(CustomSwipeActionModifier(config: config, actions: actions()))
    }
}

/// Helper View Modifier
fileprivate struct CustomSwipeActionModifier: ViewModifier {
    var config: ActionConfig
    var actions: [SwipeAction]
    
    /// View Properties
    @State private var resetPositionTrigger: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Rectangle()
                    .fill(.clear)
                    .containerRelativeFrame(config.occupiesFullWidth ? .horizontal : .vertical)
                    .overlay(alignment: .trailing) {
                        ActionsView()
                    }
            }
    }
    
    /// Action View
    @ViewBuilder
    func ActionsView() -> some View {
        ZStack {
            ForEach(actions.indices, id: \.self) { index in
                let action = actions[index]
                
                GeometryReader { proxy in
                    let size = proxy.size
                    
                    Button {
                        action.action(&resetPositionTrigger)
                    } label: {
                        Image(action.symbolImage)
                            .font(action.font)
                            .foregroundStyle(action.tint)
                            .frame(width: size.width, height: size.height)
                            .background(action.background, in: action.shape)
                    }
                }
                .frame(width: action.size.width, height: action.size.height)
            }
        }
        .visualEffect { content, proxy in
            content
                .offset(x: proxy.size.width)
        }
    }
}

#Preview {
    SwipeTestView()
}
