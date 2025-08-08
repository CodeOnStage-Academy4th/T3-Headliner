//
//  CustomTextFieldStyle.swift
//  Headliner
//
//  Created by Soop on 8/9/25.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.pretendardMedium18)
            .foregroundStyle(Color.white)
            .padding(.vertical, 17)
            .padding(.leading, 20)
            .frame(maxWidth: .infinity)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .overlay {
                RoundedRectangle(cornerRadius: 40).strokeBorder(Color.white.opacity(0.6))
            }
    }
}

