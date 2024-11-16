//
//  StrokeButton.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct StokeButton: View {
    var title: String
    var action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(title)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(DripColor.primary500Primary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(DripColor.primary500Primary, lineWidth: 2)
                )
        }
    }
}

#Preview {
    StokeButton(title: "Button Title")
        .padding()
}
