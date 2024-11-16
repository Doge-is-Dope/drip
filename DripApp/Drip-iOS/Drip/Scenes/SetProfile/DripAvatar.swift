//
//  DripAvatar.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct DripAvatar: View {
    let components: [Int]?
    let size: CGFloat

    var body: some View {
        if let components, components.count == 5 {
            ZStack {
                AvatarLayer(imageName: "bg-\(components[0])")
                AvatarLayer(imageName: "body-\(components[1])")
                AvatarLayer(imageName: "head-\(components[2])")
                AvatarLayer(imageName: "glasses-\(components[3])")
                AvatarLayer(imageName: "accessory-\(components[4])")
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(DripColor.primary500Primary, lineWidth: 4)
            )
        } else {
            ZStack {
                Color.init(red: 213 / 255, green: 215 / 255, blue: 225 / 255)
                Image(.avatarPlaceholder)
                    .resizable()
                    .frame(width: size * 0.85, height: size * 0.85)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(DripColor.primary500Primary, lineWidth: 4)
            )
        }
    }
}

struct AvatarLayer: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    DripAvatar(components: nil, size: 200)
}
