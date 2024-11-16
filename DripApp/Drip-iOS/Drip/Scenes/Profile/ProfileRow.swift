//
//  ProfileRow.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ProfileRow: View {
    @State var iconName: String
    @Binding var text: String
    var onTap: (() -> Void)?

    init(iconName: String, text: Binding<String>, onTap: (() -> Void)? = nil) {
        self._text = text
        self.iconName = iconName
        self.onTap = onTap
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(DripColor.primary500Disabled)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
        }
        .padding(.all, 12)
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    ProfileRow(iconName: "wallet-addr", text: .constant("0xb07dBaa1103e88f41BC906744b294716ed3882c4"))
        .padding()
}
