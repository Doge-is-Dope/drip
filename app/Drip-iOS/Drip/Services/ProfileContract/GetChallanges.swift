//
//  GetChallanges.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

struct GetChallenges: ABIFunction {
    static let name = "getChallenges"

    let contract: web3.EthereumAddress
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    let from: web3.EthereumAddress? = nil

    private let profileId: BigUInt
    private let epochId: BigUInt

    init(contract: web3.EthereumAddress, profileId: BigUInt, epochId: BigUInt) {
        self.contract = contract
        self.profileId = profileId
        self.epochId = epochId
    }

    public func encode(to encoder: web3.ABIFunctionEncoder) throws {
        try encoder.encode(profileId)
        try encoder.encode(epochId)
    }
}

struct GetChallengesResponse: ABIResponse {
    static var types: [web3.ABIType.Type] = [ABIArray<DripChallengeDetail>.self]

    var challenges: [DripChallenge] = []

    init?(values: [web3.ABIDecoder.DecodedValue]) throws {
        return nil
    }

    init?(data: String) throws {
        do {
            let result = try ABIDecoder.decodeData(data, types: [ABIArray<DripChallengeDetail>.self])
            challenges = try result[0].decodedTupleArray()
        } catch {
            print("Fail to decode profile data: \(error)")
            return nil
        }
    }
}

