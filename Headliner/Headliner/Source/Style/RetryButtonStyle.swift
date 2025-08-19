//
//  RetryButtonStyle.swift
//  Headliner
//
//  Created by Henry on 8/19/25.
//

import SwiftUI

struct RetryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 21)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color(hex: "#6D7079")))
    }
}
