//
//  ApproveTransfer.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import BigInt
import web3

struct ApproveTransfer: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "approve"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress

    // function params
    private let spender: EthereumAddress
    private let amount: BigInt

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        spender: EthereumAddress,
        amount: BigInt
    ) {
        self.from = from
        self.contract = contract
        self.spender = spender
        self.amount = amount
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(spender)
        try encoder.encode(amount)
    }
}
