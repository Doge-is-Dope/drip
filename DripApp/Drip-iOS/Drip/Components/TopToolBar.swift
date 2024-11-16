//
//  TopToolBar.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct TopToolBar: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }, label: {
                Image(.back)
                    .resizable()
                    .clipped()
                    .frame(width: 22 ,height: 22)
                    .padding(.all, 8)
            })
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
    }
}

#Preview {
    TopToolBar()
}
