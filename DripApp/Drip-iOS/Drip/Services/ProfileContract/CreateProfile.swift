//
//  CreateProfile.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import BigInt
import web3

struct CreateProfile: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "createProfile"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress

    // function params
    private let ownerAddress: EthereumAddress
    private let userHandle: String
    private let avatarComponents: [UInt32]

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        ownerAddress: String,
        userHandle: String,
        avatarComponents: [Int]
    ) {
        self.from = from
        self.contract = contract
        self.ownerAddress = EthereumAddress(stringLiteral: ownerAddress)
        self.userHandle = userHandle
        self.avatarComponents = avatarComponents.map { UInt32($0) }
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(ownerAddress)
        try encoder.encode(userHandle)
        try encoder.encode(avatarComponents)
    }
}
