//
//  DripChallengeContract.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class DripChallengeContract {
    private let rpcService: RPCService
    private let contractAddress: EthereumAddress
    
    init(rpcService: RPCService, contractAddress: String) {
        self.rpcService = rpcService
        self.contractAddress = EthereumAddress(stringLiteral: contractAddress)
    }
    
    func getChallengeDetail(tokenId: BigUInt) async -> DripChallenge? {
        do {
            let response = try await GetChallengeDetail(contract: contractAddress, tokenId: tokenId)
                .call(withClient: rpcService.client, responseType: GetChallengeDetailResponse.self)
            return response.challenge
        } catch {
            print("Fail to get challenge: \(error)")
            return nil
        }
    }
    
    func submitDailyCheck(tokenId: BigUInt, day: UInt16) async -> Bool {
        let submitDailyCheck = SubmitDailyCompletion(
            from: rpcService.rawAddress,
            contract: contractAddress,
            ownerAddress: rpcService.rawAddress,
            tokenId: tokenId,
            day: day
        )
        let result = await rpcService.sendTransaction(submitDailyCheck)
        switch result {
        case let .success(txHash):
            await rpcService.waitForTxSuccess(txHash: txHash)
            return true
        case let .failure(error):
            print("Fail to submit daily check: \(error)")
            return false
        }
    }
}
