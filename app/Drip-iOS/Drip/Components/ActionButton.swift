//
//  ActionButton.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ActionButton: View {
    var title: String
    var action: (() -> Void)?
    let backgroundColor: Color

    init(title: String, backgroundColor: Color = DripColor.primary500Primary, action: (() -> Void)? = nil) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .padding(.init(12))
                .frame(maxWidth: .infinity)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
      }
}

#Preview {
    ActionButton(
        title: "Button Title",
        backgroundColor: DripColor.warning,
        action: nil
    )
    .padding()
}

