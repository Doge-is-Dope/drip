//
//  ClaimReward.swift
//  Drip
//
//  Created by Shane Chi on 2024/11/16.
//

import Foundation
import BigInt
import web3

struct ClaimReward: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "setBalance"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress

    // function params
    private let ownerAddress: EthereumAddress
    private let amount: BigUInt

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        ownerAddress: String,
        amount: BigUInt
    ) {
        self.from = from
        self.contract = contract
        self.ownerAddress = EthereumAddress(stringLiteral: ownerAddress)
        self.amount = amount
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(ownerAddress)
        try encoder.encode(amount)
    }
}
