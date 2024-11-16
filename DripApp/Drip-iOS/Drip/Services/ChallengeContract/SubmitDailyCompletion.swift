//
//  SubmitDailyCompletion.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import BigInt
import web3

struct SubmitDailyCompletion: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "submitDailyCompletion"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress

    // function params
    private let ownerAddress: EthereumAddress
    private let tokenId: BigUInt
    private let day: UInt16

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        ownerAddress: EthereumAddress,
        tokenId: BigUInt,
        day: UInt16
    ) {
        self.from = from
        self.contract = contract
        self.ownerAddress = ownerAddress
        self.tokenId = tokenId
        self.day = day
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(ownerAddress)
        try encoder.encode(tokenId)
        try encoder.encode(day)
    }
}
