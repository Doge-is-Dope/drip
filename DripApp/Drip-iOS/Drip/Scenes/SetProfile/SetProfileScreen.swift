//
//  SetProfileScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct SetProfileScreen: View {
    
    var onSignIn: (() -> Void)?

    @StateObject private var viewModel: SetProfileViewModel
    @State private var username: String = ""

    init(viewModel: SetProfileViewModel, onSignIn: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignIn = onSignIn
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Set Profile")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.black)
                .frame(height: 32)
            VStack(spacing: 12) {
                DripAvatar(
                    components: [
                        viewModel.avatarBg, 
                        viewModel.avatarBody,
                        viewModel.avatarHead,
                        viewModel.avatarGlasses,
                        viewModel.avatarAccessory
                    ],
                    size: 200
                )
                Button(action: {
                    viewModel.randomlyGenerateAvatar()
                }) {
                    Text("Generate Nouns!")
                        .font(.custom("LondrinaSolid-Regular", size: 36))
                        .foregroundStyle(DripColor.primary500Primary)
                        .frame(height: 43)
                }
            }
            VStack(spacing: 4) {
                Text("Name")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DripColor.primary500Disabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20)
                TextInputField(text: $username, placeholder: "Enter your name")
                    .foregroundStyle(DripColor.mainText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            Spacer()
            ActionButton(title: "Done") {
                viewModel.setProfile(userHandle: username)
            }
        }
        .padding(.init(top: 24, leading: 24, bottom: 40, trailing: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundGrey.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isProfileCreated) {
            guard viewModel.isProfileCreated else { return }
            onSignIn?()
        }
    }
}
