//
//  ChallengeManagerContract.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class ChallengeManagerContract {
    private let rpcService: RPCService
    private let contractAddress: EthereumAddress

    init(rpcService: RPCService, contractAddress: String) {
        self.rpcService = rpcService
        self.contractAddress = EthereumAddress(stringLiteral: contractAddress)
    }

    func getEpochInfo() async -> DripEpochInfo? {
        do {
            let epochId = DripProfileContract.epochId
            let response = try await GetEpochInfo(
                contract: contractAddress,
                epochId: epochId
            ).call(
                withClient: rpcService.client,
                responseType: GetEpochInfoResponse.self
            )
            return response.ecpochInfo
        } catch {
            print("Fail to get epoch info: \(error)")
            return nil
        }
    }
}
