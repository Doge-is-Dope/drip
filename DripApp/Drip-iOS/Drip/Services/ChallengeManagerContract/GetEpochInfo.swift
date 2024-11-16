//
//  GetEpochInfo.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

struct GetEpochInfo: ABIFunction {
    static let name = "getEpochInfo"

    let contract: web3.EthereumAddress
    let gasPrice: BigUInt? = nil
    let gasLimit: BigUInt? = nil
    let from: web3.EthereumAddress? = nil
    
    private let epochId: BigUInt

    init(contract: web3.EthereumAddress, epochId: BigUInt) {
        self.contract = contract
        self.epochId = epochId
    }

    public func encode(to encoder: web3.ABIFunctionEncoder) throws {
        try encoder.encode(epochId)
    }
}

struct GetEpochInfoResponse: ABIResponse {
    static var types: [web3.ABIType.Type] = [DripEpochInfo.self, UInt8.self]
    let ecpochInfo: DripEpochInfo

    init?(values: [web3.ABIDecoder.DecodedValue]) throws {
        return nil
    }

    init?(data: String) throws {
        do {
            let result = try ABIDecoder.decodeData(data, types: [DripEpochInfo.self, UInt8.self])
            self.ecpochInfo = try result[0].decoded()
        } catch {
            print("Fail to decode profile data: \(error)")
            return nil
        }
    }
}
