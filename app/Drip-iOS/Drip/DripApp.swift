//
//  DripApp.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import SwiftData
import web3

@main
struct DripApp: App {
    private let web3AuthService: Web3AuthService = Web3AuthService()

    @State private var userSessionState: UserSessionState = .launching

    var body: some Scene {
        WindowGroup {
            switch userSessionState {
            case .launching:
                configLaunchScreen()
            case .guest:
                NavigationStack {
                    configSignInScreen()
                }
            case .active:
                NavigationStack {
                    configChallengePoolScreen()
                }
            }
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

// MARK: - Private functions
extension DripApp {
    private func configLaunchScreen() -> LaunchScreen {
        let viewModel = LaunchViewModel(web3AuthService: web3AuthService)
        let launchScreen = LaunchScreen(viewModel: viewModel) {
            getDripUserProfile()
        }
        return launchScreen
    }

    private func configSignInScreen() -> SignInScreen {
        let viewModel = SignInViewModel(web3AuthService: web3AuthService)
        let sigInScreen = SignInScreen(viewModel: viewModel) {
            getDripUserProfile()
        }
        return sigInScreen
    }

    private func configChallengePoolScreen() -> ChallengePoolScreen {
        guard let user = web3AuthService.user,
              let rpcService = RPCService(user: user, rpcURL: BlockchainEnv.rpcURL, chainId: BlockchainEnv.chainId) else {
            fatalError("Fail to initialize RPCService")
        }
        let viewModel = ChallengePoolViewModel(rpcService: rpcService)
        let challengePoolScreen = ChallengePoolScreen(viewModel: viewModel) {
            Task {
                if await web3AuthService.logOut() {
                    DispatchQueue.main.async {
                        userSessionState = .guest
                    }
                }
            }
        }
        return challengePoolScreen
    }

    private func getDripUserProfile() {
        if let user = web3AuthService.user {
            print("Web3Auth User Info:")
            print(user.privKey ?? "")
            print((try? EthereumAccount(keyStorage: user))?.address.asString() ?? "")

            let rpcService = RPCService(user: user, rpcURL: BlockchainEnv.rpcURL, chainId: BlockchainEnv.chainId)
            let profileContract = DripProfileContract(rpcService: rpcService!, contractAddress: DripContracts.profile)
            Task {
                let result = await profileContract.getProfile()
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        userSessionState = .active
                    case .failure:
                        userSessionState = .guest
                    }
                }
            }
        } else {
            userSessionState = .guest
        }
    }
}
