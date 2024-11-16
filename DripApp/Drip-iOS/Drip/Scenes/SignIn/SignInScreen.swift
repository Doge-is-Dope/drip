//
//  SignInScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import ProgressHUD

struct SignInScreen: View {

    var onSignIn: (() -> Void)?

    @StateObject private var viewModel: SignInViewModel
    @State private var emailText: String = ""

    init(viewModel: SignInViewModel, onSignIn: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignIn = onSignIn
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(.dripLogo)
                .resizable()
                .frame(width: 114 ,height: 120)
            Text("Welcome")
                .foregroundStyle(.black)
                .font(.custom("LondrinaSolid-Regular", size: 36))
                .frame(height: 58)
            Text("Enter your email address to start!")
                .foregroundStyle(DripColor.primary500Disabled)
                .font(.system(size: 16, weight: .regular))
                .frame(height: 24)
            Spacer().frame(height: 8)
            TextInputField(text: $emailText, placeholder: "Email")
                .foregroundStyle(DripColor.mainText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
            Spacer()
            ActionButton(title: "Sign in With Web3Auth") {
                ProgressHUD.animate("Almost there 🤜🤛")
                viewModel.signIn(with: emailText)
            }
        }
        .padding(.init(top: 30, leading: 28, bottom: 40, trailing: 28))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundGrey.ignoresSafeArea())
        .onChange(of: viewModel.isSignedIn) {
            guard viewModel.isSignedIn else { return }
            ProgressHUD.dismiss()
            onSignIn?()
            viewModel.isSignedIn = false
        }
        .onChange(of: viewModel.needToSetProfile) {
            if viewModel.needToSetProfile {
                ProgressHUD.dismiss()
                viewModel.isSignedIn = false
            }
        }
        .navigationDestination(isPresented: $viewModel.needToSetProfile) {
            if let rpcService = viewModel.rpcService {
                let setProfileViewModel = SetProfileViewModel(rpcService: rpcService)
                SetProfileScreen(viewModel: setProfileViewModel) {
                    onSignIn?()
                }
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    let viewModel = SignInViewModel(web3AuthService: Web3AuthService())
    return SignInScreen(viewModel: viewModel)
}
