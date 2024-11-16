//
//  ChallengePoolViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class ChallengePoolViewModel: ObservableObject {
    @Published var challenges: [DripChallenge] = []
    @Published var epochInfo: DripEpochInfo?

    let rpcService: RPCService

    private lazy var profileContract = DripProfileContract(rpcService: rpcService, contractAddress: DripContracts.profile)
    private lazy var challengeManagerContract = ChallengeManagerContract(rpcService: rpcService, contractAddress: DripContracts.challengeManager)

    init(rpcService: RPCService) {
        self.rpcService = rpcService
    }

    func fetchChallenges(refresh: Bool = false) {
        DispatchQueue.main.async {
            self.challenges = []
        }
        Task {
            let challenges = await profileContract.getChallenges()
            print(challenges)
            DispatchQueue.main.async {
                self.challenges = challenges
            }
            print("Fetch challenges. Count: \(challenges.count)")
        }
    }

    func fetchEpochInfo() {
        Task {
            if let epochInfo = await challengeManagerContract.getEpochInfo() {
                print("get epoch info: \(epochInfo)")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.epochInfo = epochInfo
                }
            }
        }
    }
}
