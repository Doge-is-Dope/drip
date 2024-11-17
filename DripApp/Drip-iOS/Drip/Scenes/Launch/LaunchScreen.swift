//
//  LaunchScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct LaunchScreen: View {
    var setUpCompletion: (() -> Void)?

    @StateObject private var viewModel: LaunchViewModel

    init(viewModel: LaunchViewModel, setUpCompletion: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.setUpCompletion = setUpCompletion
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(.dripLogo)
                .resizable()
                .frame(width: 152, height: 160)
            VStack(spacing: 12) {
                Image(.dripWordMarkBlack)
                    .resizable()
                    .frame(width: 148, height: 86)
                Text("Never drop.")
                    .font(.system(size: 18, weight: .light))
                    .frame(height: 28)
                    .foregroundStyle(DripColor.primary500Disabled)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundMain.ignoresSafeArea())
        .onAppear {
            viewModel.setUp()
        }
        .onChange(of: viewModel.isSetUpComplete) {
            guard viewModel.isSetUpComplete else { return }
            setUpCompletion?()
        }
    }
}

#Preview {
    let viewModel = LaunchViewModel(web3AuthService: Web3AuthService())
    return LaunchScreen(viewModel: viewModel)
}
