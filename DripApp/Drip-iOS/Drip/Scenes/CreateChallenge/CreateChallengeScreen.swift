//
//  CreateChallengeScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import ProgressHUD

struct CreateChallengeScreen: View {
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var days: String = ""
    @State private var desc: String = ""
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CreateChallengeViewModel

    init(viewModel: CreateChallengeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Create Challenge")
                .font(.system(size: 24, weight: .medium))
                .frame(height: 32)
                .foregroundStyle(.black)
            VStack(spacing: 4) {
                Text("Name")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DripColor.primary500Disabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20)
                TextInputField(text: $name, placeholder: "Enter your challenge name")
                    .foregroundStyle(DripColor.mainText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            VStack(spacing: 4) {
                Text("Stake Amount")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DripColor.primary500Disabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20)
                TextInputField(text: $amount, placeholder: "Enter amount to stake")
                    .foregroundStyle(DripColor.mainText)
                    .keyboardType(.numbersAndPunctuation)
            }
            VStack(spacing: 4) {
                Text("Duration Days")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DripColor.primary500Disabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20)
                TextInputField(text: $days, placeholder: "Enter duration days")
                    .foregroundStyle(DripColor.mainText)
                    .keyboardType(.numberPad)
            }
            VStack(spacing: 4) {
                Text("Description")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DripColor.primary500Disabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20)
                TextInputField(text: $desc, placeholder: "Enter the description")
                    .foregroundStyle(DripColor.mainText)
            }
            Spacer()
            ActionButton(title: "Create", backgroundColor: DripColor.warning) {
                ProgressHUD.animate("Almost there 🤜🤛")
                viewModel.createChallenge(name: name, desc: desc, stakeAmount: amount)
            }
        }
        .padding(.init(top: 24, leading: 24, bottom: 40, trailing: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundMain.ignoresSafeArea())
        .onChange(of: viewModel.isChallengeCreated) {
            if viewModel.isChallengeCreated {
                dismiss()
                ProgressHUD.dismiss()
            }
        }
    }
}
