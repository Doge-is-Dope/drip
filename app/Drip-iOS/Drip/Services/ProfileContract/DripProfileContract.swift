//
//  ProfileContract.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class DripProfileContract {
    private let rpcService: RPCService
    private let contractAddress: EthereumAddress

    static var profileId: BigUInt? = nil
    static var epochId: BigUInt = 1

    init(rpcService: RPCService, contractAddress: String) {
        self.rpcService = rpcService
        self.contractAddress = EthereumAddress(stringLiteral: contractAddress)
    }

    func createProfile(userHandle: String, avatarComponents: [Int]) async -> Bool {
        let createProfileFunction = CreateProfile(
            from: rpcService.rawAddress,
            contract: contractAddress,
            ownerAddress: rpcService.accountAddress,
            userHandle: userHandle, avatarComponents: avatarComponents
        )
        let result = await rpcService.sendTransaction(createProfileFunction)
        switch result {
        case let .success(txHash):
            await rpcService.waitForTxSuccess(txHash: txHash)
            return true
        case let .failure(error):
            print("Fail to create profile: \(error)")
            return false
        }
    }

    func getProfile() async -> Result<DripProfile, Error> {
        do {
            let response = try await GetProfile(
                contract: EthereumAddress(stringLiteral: DripContracts.profile),
                ownerAddr: rpcService.rawAddress
            ).call(withClient: rpcService.client, responseType: GetProfileResponse.self)
            let profile = response.profile
            DripProfileContract.profileId = profile.rawTokenId
            return .success(profile)
        } catch {
            print("Fail to get profile: \(error)")
            return .failure(error)
        }
    }

    func getChallenges() async -> [DripChallenge]  {
        guard let profileId = Self.profileId else {
            fatalError("Invalid profile id")
        }
        do {
            let response = try await GetChallenges(
                contract:  EthereumAddress(stringLiteral: DripContracts.profile),
                profileId: profileId,
                epochId: DripProfileContract.epochId
            ).call(withClient: rpcService.client, responseType: GetChallengesResponse.self)
            return response.challenges
        } catch {
            print("Fail to get profile: \(error)")
            return []
        }
    }

    func createChallenge(
        name: String,
        desc: String,
        stakeAmount: BigUInt
    ) async -> Bool {
        guard let profileId = Self.profileId else {
            fatalError("Invalid profile id")
        }
        let createChallengeFunction = CreateChallenge(
            from: rpcService.rawAddress,
            contract: contractAddress,
            profileId: profileId,
            name: name,
            desc: desc,
            stakeToken: EthereumAddress(stringLiteral: DripContracts.dripERC20Token),
            stakeAmount: stakeAmount,
            duration: 5
        )
        let result = await rpcService.sendTransaction(createChallengeFunction)
        switch result {
        case let .success(txHash):
            await rpcService.waitForTxSuccess(txHash: txHash)
            return true
        case let .failure(error):
            print("Fail to create profile: \(error)")
            return false
        }
    }
}
