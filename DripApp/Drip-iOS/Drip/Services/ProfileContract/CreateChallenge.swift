//
//  CreateChallenge.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import BigInt
import web3

struct CreateChallenge: ABIFunction {
    public var from: web3.EthereumAddress?

    public static let name = "createChallenge"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress

    // function params
    let profileId: BigUInt
    let name: String
    let desc: String
    let stakeToken: EthereumAddress
    let stakeAmount: BigUInt
    let duration: UInt16

    init(
        from: web3.EthereumAddress?,
        contract: EthereumAddress,
        profileId: BigUInt,
        name: String,
        desc: String,
        stakeToken: EthereumAddress,
        stakeAmount: BigUInt,
        duration: UInt16
    ) {
        self.from = from
        self.contract = contract
        self.profileId = profileId
        self.name = name
        self.desc = desc
        self.stakeToken = stakeToken
        self.stakeAmount = stakeAmount
        self.duration = duration
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(profileId)
        try encoder.encode(name)
        try encoder.encode(desc)
        try encoder.encode(stakeAmount)
        try encoder.encode(duration)
    }
}


struct CreateChallengeTuple: ABITuple {
    static var types: [ABIType.Type] { [
        BigUInt.self,
        String.self,
        String.self,
        BigUInt.self,
        UInt16.self
    ] }

    let profileId: BigUInt
    let name: String
    let desc: String
    let stakeAmount: BigUInt
    let duration: UInt16

    init(
        profileId: BigUInt,
        name: String,
        desc: String,
        stakeToken: EthereumAddress,
        stakeAmount: BigUInt,
        duration: UInt16
    ) {
        self.profileId = profileId
        self.name = name
        self.desc = desc
        self.stakeAmount = stakeAmount
        self.duration = duration
    }

    init?(values: [ABIDecoder.DecodedValue]) throws {
        return nil
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(profileId)
        try encoder.encode(name)
        try encoder.encode(desc)
        try encoder.encode(stakeAmount)
        try encoder.encode(duration)
    }

    var encodableValues: [ABIType] { [
        profileId,
        name,
        desc,
        stakeAmount,
        duration
    ] }
}
