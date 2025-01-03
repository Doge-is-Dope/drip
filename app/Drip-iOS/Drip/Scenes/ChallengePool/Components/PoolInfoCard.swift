//
//  PoolInfoCard.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import BigInt

struct PoolInfoCard: View {
    @Binding var epochInfo: DripEpochInfo?
    @Binding var isActive: Bool

    private var poolName: String  {
        isActive ? "Active Pool" : "Finished Pool"
    }
    private var buttonTitle: String {
        isActive ? "View Leaderboard" : "Claim Rewards"
    }
    private var bgColor: Color {
        isActive ? DripColor.activePoolBg : DripColor.primary500Primary.opacity(0.2)
    }
    private var img: Image {
        isActive ? Image(.poolActive) : Image(.poolEnded)
    }

    private var participantsCount: String {
        if isActive { return "10" }
        return epochInfo?.displayedParticipants ?? "-"
    }

    private var timeRemaining: String {
        if isActive {
            let hours = epochInfo?.hoursRemaining() ?? 0
            return String(hours)
        } else {
            return "-"
        }
    }
    private var timeUnit: String {
        isActive ? "Hours Remaining" : "Days Remaining"
    }

    private var totalStakedAmount: String {
        epochInfo?.totalStakedAmount ?? "-"
    }

    var onButtonTap: (() -> Void)?
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poolName)
                        .font(.custom("LondrinaSolid-Regular", size: 36))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(epochInfo?.description ?? "-")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(DripColor.primary500Disabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height: 4)
                    Button(action: {
                        onButtonTap?()
                    }) {
                        Text(buttonTitle)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(.white)
                            .background(.black)
                            .font(.system(size: 14))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                img.resizable().frame(width: 98, height: 80)
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 16)
            .background(bgColor)
            HStack {
                PoolInfoChip(mainText: .constant(timeRemaining), subText: .constant(timeUnit))
                PoolInfoChip(mainText: .constant(participantsCount), subText: .constant("Participants"))
                PoolInfoChip(mainText: .constant(totalStakedAmount), subText: .constant("\(DripContracts.dripERC20TokenSymbol) Staked"))
            }
            .padding(.all, 16)
            .background(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 0)
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black, lineWidth: 2)
        )
    }
}
