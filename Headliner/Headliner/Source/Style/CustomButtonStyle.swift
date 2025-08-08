//
//  CustomButtonStyle.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // TODO: SF Pro
            .foregroundStyle(Color.white)
            .padding(.horizontal, 55)
            .padding(.vertical, 21)
            .background(LinearGradient.componentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color(hex: "#FFD4FE66").opacity(0.4)))
    }
}
