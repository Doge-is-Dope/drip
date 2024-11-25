//
//  GetProfileByAddress.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

struct GetProfile: ABIFunction {
    static let name = "getProfileByOwner"

    let contract: web3.EthereumAddress
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    let from: web3.EthereumAddress? = nil

    private let ownerAddr: EthereumAddress

    init(contract: web3.EthereumAddress, ownerAddr: EthereumAddress) {
        self.contract = contract
        self.ownerAddr = ownerAddr
    }

    public func encode(to encoder: web3.ABIFunctionEncoder) throws {
        try encoder.encode(ownerAddr)
    }
}

struct GetProfileResponse: ABIResponse {
    static var types: [web3.ABIType.Type] = [DripProfile.self]

    let profile: DripProfile

    init?(values: [web3.ABIDecoder.DecodedValue]) throws {
        return nil
    }

    init?(data: String) throws {
        do {
            let result = try ABIDecoder.decodeData(data, types: [DripProfile.self])
            self.profile = try result[0].decoded()
        } catch {
            print("Fail to decode profile data: \(error)")
            return nil
        }
    }
}
