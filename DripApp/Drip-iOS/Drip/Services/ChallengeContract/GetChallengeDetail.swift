//
//  GetChallengeDetail.swift
//  Drip
//
//  Created by Shane Chi 

import Foundation
import web3
import BigInt

struct GetChallengeDetail: ABIFunction {
    static let name = "getChallenge"

    let contract: web3.EthereumAddress
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    let from: web3.EthereumAddress? = nil

    private let tokenId: BigUInt

    init(
        contract: web3.EthereumAddress,
        tokenId: BigUInt
    ) {
        self.contract = contract
        self.tokenId = tokenId
    }

    public func encode(to encoder: web3.ABIFunctionEncoder) throws {
        try encoder.encode(tokenId)
    }
}

struct GetChallengeDetailResponse: ABIResponse {
    static var types: [web3.ABIType.Type] = [DripChallengeDetail.self]

    let challenge: DripChallenge

    init?(values: [web3.ABIDecoder.DecodedValue]) throws {
        return nil
    }

    init?(data: String) throws {
        do {
            let result = try ABIDecoder.decodeData(data, types: [DripChallengeDetail.self])
            challenge = try result[0].decoded()
        } catch {
            print("Fail to decode profile data: \(error)")
            return nil
        }
    }
}
