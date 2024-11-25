//
//  QuestViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class QuestViewModel: ObservableObject {
    @Published var challenge: DripChallenge
    @Published var isDailyCheckSubmit = false
    let rpcService: RPCService
    
    private let dayIndex: Int
    private lazy var challengeContract = DripChallengeContract(rpcService: rpcService, contractAddress: DripContracts.challenge)

    init(challenge: DripChallenge, rpcService: RPCService, dayIndex: Int) {
        self.challenge = challenge
        self.rpcService = rpcService
        self.dayIndex = dayIndex
    }

    func submitDailyCheck() {
        Task {
            do {
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                let isSuccessful = await challengeContract.submitDailyCheck(tokenId: challenge.rawId, day: UInt16(dayIndex))
                if isSuccessful {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.isDailyCheckSubmit = true
                    }
                }
            } catch {
                print("fail to submit daily")
            }
        }
    }
}
