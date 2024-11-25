//
//  TextInputField.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct TextInputField: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .background(.clear)
                    .foregroundColor(DripColor.primary500Disabled)
                    .font(.system(size: 14))
                    .padding(.leading, 10)
            }
            TextField(placeholder, text: $text)
                .background(.clear)
                .padding(.init(10 ))
                .foregroundStyle(.black)
                .font(.system(size: 14))
                .focused($isFocused)
        }
        .background(isFocused ? DripColor.primary500Primary.opacity(0.03) : .white)
        .cornerRadius(8)
        .overlay(
             RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? DripColor.primary500Primary :
                    Color(red: 238 / 255, green: 238 / 255, blue: 238 / 255), lineWidth: 1)
         )
    }
}

struct TextInputField_Previews: PreviewProvider {
    @State static var sampleText: String = ""

    static var previews: some View {
        VStack {
            TextInputField(text: $sampleText, placeholder: "Enter text here")
                .padding()
        }.background(DripColor.backgroundMain)
    }
}
