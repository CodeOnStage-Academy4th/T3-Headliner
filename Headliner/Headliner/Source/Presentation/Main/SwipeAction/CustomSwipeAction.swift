//
//  CustomSwipeAction.swift
//  Headliner
//
//  Created by Subeen on 8/28/25.
//

import SwiftUI

struct SwipeAction: Identifiable {
    var id = UUID().uuidString
    var symbolImage: UIImage

    /// View Properties
    var size: CGSize = .init(width: 45, height: 45)
    var shape: AnyShape = AnyShape(Rectangle())
    var action: (inout Bool) -> ()
}

/// Type-erased Shape wrapper
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

/// Swipe Action Builder
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
    @State private var offset: CGFloat = 0
    @State private var resetPositionTrigger: Bool = false
    @State private var isHorizontalDrag: Bool? = nil

    var actionsWidth: CGFloat {
        let totalWidth = actions.reduce(0) { $0 + $1.size.width }
        let spacing = CGFloat(max(0, actions.count - 1)) * config.spacing
        return totalWidth + spacing + config.leadingPadding + config.trailingPadding
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            // 배경의 액션 버튼들 - 오른쪽 화면 밖에 숨겨두고 스와이프 시 나타남
            ActionsView()
                .offset(x: actionsWidth + offset)

            // 컨텐츠
            content
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 15)
                        .onChanged { value in
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)

                            // 처음 드래그 방향 판별
                            if isHorizontalDrag == nil {
                                isHorizontalDrag = horizontal > vertical
                            }

                            // 수평 드래그인 경우에만 offset 업데이트
                            if isHorizontalDrag == true {
                                let translation = value.translation.width
                                // 왼쪽으로 스와이프만 허용 (음수값)
                                offset = min(0, max(-actionsWidth * 1.5, translation))
                            }
                        }
                        .onEnded { value in
                            // 드래그 방향 초기화
                            defer { isHorizontalDrag = nil }

                            // 수평 드래그가 아니었으면 아무것도 하지 않음 (스크롤 허용)
                            guard isHorizontalDrag == true else {
                                return
                            }

                            let translation = value.translation.width
                            let velocity = value.predictedEndTranslation.width

                            // 삭제 버튼이 완전히 나타난 후(actionsWidth) + 추가로 더 스와이프해야 삭제
                            let fullSwipeThreshold = actionsWidth * 1.8
                            let velocityThreshold = actionsWidth * 3

                            // Full swipe: 버튼 너비의 1.8배 이상 드래그하거나 매우 빠른 속도로 스와이프
                            if -translation > fullSwipeThreshold || -velocity > velocityThreshold {
                                // 햅틱 피드백
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()

                                // 삭제 액션 실행
                                if let firstAction = actions.first {
                                    var trigger = resetPositionTrigger
                                    firstAction.action(&trigger)
                                    resetPositionTrigger = trigger
                                }
                                withAnimation(.snappy) {
                                    offset = 0
                                }
                            } else {
                                withAnimation(.snappy) {
                                    // 절반 이상 스와이프하면 열린 상태 유지
                                    if -translation > actionsWidth / 2 {
                                        offset = -actionsWidth
                                    } else {
                                        offset = 0
                                    }
                                }
                            }
                        }
                )
        }
        .clipped()
        .onChange(of: resetPositionTrigger) { _, _ in
            withAnimation(.snappy) {
                offset = 0
            }
        }
        .onChange(of: isHorizontalDrag) { _, newValue in
            // 수직 드래그로 판별되면 offset 초기화
            if newValue == false {
                offset = 0
            }
        }
    }

    /// Action View
    @ViewBuilder
    func ActionsView() -> some View {
        HStack(spacing: config.spacing) {
            ForEach(actions) { action in
                Button {
                    action.action(&resetPositionTrigger)
                } label: {
                    Image(uiImage: action.symbolImage)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, config.leadingPadding)
        .padding(.trailing, config.trailingPadding)
    }
}

#Preview {
    SwipeTestView()
}
