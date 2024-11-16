//
//  ChallengeCell.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ChallengeCell: View {
    var body: some View {
        VStack(spacing: 0) {
            DripColor.primary500Primary.aspectRatio(1, contentMode: .fill)
                .padding(.bottom, 10)
            Text("Hello")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(DripColor.primary500Primary)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            Text("30 USDC Staked")
                .font(.system(size: 12, weight: .thin))
                .foregroundStyle(DripColor.subText)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ChallengeCell()
        .padding()
        .background(DripColor.backgroundMain)
}
