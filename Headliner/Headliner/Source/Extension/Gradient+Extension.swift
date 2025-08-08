//
//  Gradient+Extension.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

extension LinearGradient {
    /// 배경 그라디언트
    static let backgroundGradient: LinearGradient = .init(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "002E6B"), location: 0.0),
            .init(color: Color(hex: "000000"), location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 컴포넌트 그라디언트
    static let componentGradient: LinearGradient = .init(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FF00FA"), location: 0.0),
            .init(color: Color(hex: "C127F9"), location: 1.0)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
