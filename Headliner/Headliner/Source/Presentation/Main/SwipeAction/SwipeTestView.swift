//
//  SwipeTestView.swift
//  Headliner
//
//  Created by Subeen on 8/29/25.
//

import SwiftUI

struct SwipeTestView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Rectangle()
                    .fill(.black.gradient)
                    .frame(height: 50)
                    .swipeActions {
                        
                        SwipeAction(symbolImage: .delete) { resetPosition in
                            
                        }
                    }
                    .padding(15)
                    .navigationTitle("Custom Swipe Action")
            }
        }
    }
}

#Preview {
    SwipeTestView()
}
