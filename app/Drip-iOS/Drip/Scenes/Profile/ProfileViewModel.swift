//
//  ProfileViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import Web3Auth
import BigInt

final class ProfileViewModel: ObservableObject {
    let rpcService: RPCService

    @Published var avatarComponents: [Int]?
    @Published var userHandle: String = "-"

    @Published var accountAddress: String
    @Published var email: String

    @Published var nativeTokenBalance: String = "- \(BlockchainEnv.nativeTokenSymbol)"
    @Published var dripERC20TokenBalance: String = "- \(DripContracts.dripERC20TokenSymbol)"

    private lazy var profileContract = DripProfileContract(
        rpcService: rpcService,
        contractAddress: DripContracts.profile
    )
    private lazy var dripERC20Contract = DripERC20Contract(
        rpcService: rpcService,
        contractAddress: DripContracts.dripERC20Token
    )

    init(rpcService: RPCService) {
        self.rpcService = rpcService
        self.accountAddress = rpcService.accountAddress
        self.email = (rpcService.user as? Web3AuthState)?.userInfo?.email ?? "-"

        fetchProfile()
        fetchNativeTokenBalance()
        fetchDripTokenBalance()
    }

    func fetchProfile() {
        Task {
            let result = await profileContract.getProfile()
            switch result {
            case let .success(profile):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.userHandle = profile.rawUserHandle
                    self.avatarComponents = profile.rawAvatars.map { Int($0) }
                }
            case .failure:
                print("Failed to fetch profile")
            }
        }
    }

    func fetchNativeTokenBalance() {
        Task {
            let bal = await rpcService.getBalance()
            guard let bal else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let displayedBal = bal.description.convertBigIntToDecimalFormat(decimals: 18, decimalPlaces: 6)
                self.nativeTokenBalance = "\(displayedBal) \(BlockchainEnv.nativeTokenSymbol)"
            }
        }
    }

    func fetchDripTokenBalance() {
        Task {
            if let bal = await dripERC20Contract.getBalance() {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.dripERC20TokenBalance = "\(bal) \(DripContracts.dripERC20TokenSymbol)"
                }
            }
        }
    }
}
