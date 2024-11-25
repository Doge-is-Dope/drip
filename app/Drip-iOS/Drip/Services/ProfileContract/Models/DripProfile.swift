//
//  DripProfile.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

struct DripProfile: ABITuple {
    static var types: [ABIType.Type] { [
        BigUInt.self,
        EthereumAddress.self,
        String.self,
        ABIArray<UInt32>.self
    ] }

    var rawTokenId: BigUInt
    var rawOwnerAddress: EthereumAddress
    var rawUserHandle: String
    var rawAvatars: [UInt32]

    init(
        rawTokenId: BigUInt,
        rawOwnerAddress: EthereumAddress,
        rawUserHandle: String,
        rawAvatars: [UInt32]
    ) {
        self.rawTokenId = rawTokenId
        self.rawOwnerAddress = rawOwnerAddress
        self.rawUserHandle = rawUserHandle
        self.rawAvatars = rawAvatars
    }

    init?(values: [ABIDecoder.DecodedValue]) throws {
        self.rawTokenId = try values[0].decoded()
        self.rawOwnerAddress = try values[1].decoded()
        self.rawUserHandle = try values[2].decoded()
        self.rawAvatars = []
        for idx in 3...7 {
            self.rawAvatars.append(contentsOf: try values[idx].decodedArray())
        }
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(rawTokenId)
        try encoder.encode(rawOwnerAddress)
        try encoder.encode(rawUserHandle)
        try encoder.encode(rawAvatars)
    }

    var encodableValues: [ABIType] { [
        rawTokenId,
        rawOwnerAddress,
        rawUserHandle,
        ABIArray(values: rawAvatars)
    ] }
}
