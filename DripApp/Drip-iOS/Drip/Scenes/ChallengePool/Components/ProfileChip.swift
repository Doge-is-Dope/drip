//
//  ProfileChip.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ProfileChip: View {
    var body: some View {
        HStack(spacing: 6) {
            CircleAvatar(size: 20, borderWidth: 2)
            Text("0xcB73...6Ea9")
                .foregroundStyle(DripColor.darkSub)
                .font(.system(size: 12, weight: .regular))
        }
        .padding(.init(top: 4, leading: 6, bottom: 4, trailing: 6))
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

#Preview {
    ZStack {
        DripColor.backgroundGrey
        ProfileChip()
    }
}
