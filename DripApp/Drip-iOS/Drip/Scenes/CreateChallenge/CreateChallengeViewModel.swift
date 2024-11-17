//
//  CreateChallengeViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class CreateChallengeViewModel: ObservableObject {
    let rpcService: RPCService
    @Published var isChallengeCreated = false
    
    private lazy var dripERC20Contract = DripERC20Contract(rpcService: rpcService, contractAddress: DripContracts.dripERC20Token)
    private lazy var profileContract = DripProfileContract(rpcService: rpcService, contractAddress: DripContracts.profile)

    init(rpcService: RPCService) {
        self.rpcService = rpcService
    }

    func createChallenge(name: String, desc: String, stakeAmount: String) {
        let floatValue = Float(stakeAmount) ?? 0
        let amount = BigUInt(floatValue).multiplied(by: BigUInt(10).power(18))

        Task {
            let isApproveSuccessful = await dripERC20Contract.approveTransfer(amount:  amount.multiplied(by: BigUInt(10).power(18)))
            if isApproveSuccessful {
                print("Approve success")
                let isCreateSuccessful = await profileContract.createChallenge(name: name, desc: desc, stakeAmount: amount)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isChallengeCreated = isCreateSuccessful
                }
            }
        }
    }

    //func createChallenge() {
    //    print(DripProfileContract.profileId)
    ////        Task {
    ////            let isSuccessful = await dripERC20Contract.approveTransfer(amount:  BigUInt(2.23).multiplied(by: BigUInt(10).power(18)))
    ////            if isSuccessful {
    ////                let result = await profileContract.createChallenge()
    ////                print("Challenge creation result: \(result)")
    ////            }
    ////        }
    //}
}
