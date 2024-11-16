//
//  ProfileScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ProfileScreen: View {
    var onLogOut: (() -> Void)?
    
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel, onLogOut: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLogOut = onLogOut
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Profile")
                .font(.system(size: 24, weight: .medium))
                .frame(height: 32)
                .foregroundStyle(.black)

            DripAvatar(components: viewModel.avatarComponents, size: 100)

            Text(viewModel.userHandle)
                .font(.custom("LondrinaSolid-Regular", size: 36))
                .frame(height: 44)
                .foregroundStyle(.black)

            VStack(alignment: .leading, spacing: 0) {
                ProfileRow(iconName: "wallet-addr", text: $viewModel.accountAddress) {
                    UIPasteboard.general.string = viewModel.accountAddress
                }
                ProfileRow(iconName: "email", text: $viewModel.email)
                HStack(spacing: 5) {
                    Image(.blockScoutLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("Check your account on explorer")
                        .font(.system(size: 14))
                        .foregroundStyle(DripColor.main)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 20)
                }
                .padding(.all, 12)
                .onTapGesture {
                    if let url = URL(string: "https://base-sepolia.blockscout.com/address/\(viewModel.accountAddress)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 8) {
                Text("Tokens")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 28)
                    .foregroundStyle(.black)
                VStack(alignment: .leading, spacing: 0) {
                    ProfileRow(iconName: BlockchainEnv.nativeTokenIcon, text: $viewModel.nativeTokenBalance)
                    ProfileRow(iconName: DripContracts.dripERC20TokenIcon, text: $viewModel.dripERC20TokenBalance)
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }

            Spacer()
            ActionButton(title: "Log Out", backgroundColor: DripColor.warning) {
                onLogOut?()
            }
        }
        .padding(.init(top: 24, leading: 24, bottom: 40, trailing: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundMain.ignoresSafeArea())
    }
}
