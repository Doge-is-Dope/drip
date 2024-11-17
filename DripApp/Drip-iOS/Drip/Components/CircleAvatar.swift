//
//  CircleAvatar.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct CircleAvatar: View {
    @State var avatarURL: URL?
    private let size: CGFloat
    private let borderWidth: CGFloat

    init(size: CGFloat, borderWidth: CGFloat, avatarURL: URL? = nil) {
        self.size = size
        self.borderWidth = borderWidth
        self.avatarURL = avatarURL
    }
    
    var body: some View {
        AsyncImage(url: avatarURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Image(.avatarPlaceholder)
                .resizable()
                .scaledToFill()
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(DripColor.primary500Primary, lineWidth: borderWidth)
        )
    }
}

#Preview {
    CircleAvatar(size: 50, borderWidth: 2)
}
