//
//  SignInViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import Combine

final class SignInViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var needToSetProfile: Bool = false

    var rpcService: RPCService?

    private let web3AuthService: Web3AuthService
    private var cancellables = Set<AnyCancellable>()

    init(web3AuthService: Web3AuthService) {
        self.web3AuthService = web3AuthService
        setUpBinding()
    }

    func signIn(with email: String) {
        Task {
            await web3AuthService.login(with: email)
        }
    }

    func mockSetProfile() {
        needToSetProfile = true
    }
}

extension SignInViewModel {
    private func setUpBinding() {
        web3AuthService.logInSuccessSubject
            .sink { [weak self] in
                guard let self,
                      let user = self.web3AuthService.user,
                      let rpcService = RPCService(user: user, rpcURL: BlockchainEnv.rpcURL, chainId: BlockchainEnv.chainId) else {
                    print("Fail to init RPC service")
                    return
                }
                self.rpcService = rpcService

                let profileContract = DripProfileContract(
                    rpcService: rpcService,
                    contractAddress: DripContracts.profile
                )
                Task {
                    let result = await profileContract.getProfile()
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        switch result {
                        case let .success(profile):
                            print("Get user profile: \(profile)")
                            self.isSignedIn = true
                        case .failure:
                            self.needToSetProfile = true
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
