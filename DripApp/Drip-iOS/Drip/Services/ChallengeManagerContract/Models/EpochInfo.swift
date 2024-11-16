//
//  EpochInfo.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

struct DripEpochInfo: ABITuple {
    static var types: [ABIType.Type] { [
        BigUInt.self, // id
        BigUInt.self, // startTimestamp
        BigUInt.self, // endTimestamp
        BigUInt.self, // participantCount
        BigUInt.self, // totalDeposits
        EthereumAddress.self, // vault
        EthereumAddress.self, // asset
        UInt16.self, // durationInDays
        String.self // description
    ] }

    var id: BigUInt
    var startTimestamp: BigUInt
    var endTimestamp: BigUInt
    var participantCount: BigUInt
    var totalDeposits: BigUInt
    var vault: EthereumAddress
    var asset: EthereumAddress
    var durationInDays: UInt16
    var description: String

    init(
        id: BigUInt,
        startTimestamp: BigUInt,
        endTimestamp: BigUInt,
        participantCount: BigUInt,
        totalDeposits: BigUInt,
        vault: EthereumAddress,
        asset: EthereumAddress,
        durationInDays: UInt16,
        description: String
    ) {
        self.id = id
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.participantCount = participantCount
        self.totalDeposits = totalDeposits
        self.vault = vault
        self.asset = asset
        self.durationInDays = durationInDays
        self.description = description
    }

    init?(values: [ABIDecoder.DecodedValue]) throws {
        self.id = try values[0].decoded()
        self.startTimestamp = try values[1].decoded()
        self.endTimestamp = try values[2].decoded()
        self.participantCount = try values[3].decoded()
        self.totalDeposits = try values[4].decoded()
        self.vault = try values[5].decoded()
        self.asset = try values[6].decoded()
        self.durationInDays = try values[7].decoded()
        self.description = try values[8].decoded()
    }

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(id)
        try encoder.encode(startTimestamp)
        try encoder.encode(endTimestamp)
        try encoder.encode(participantCount)
        try encoder.encode(totalDeposits)
        try encoder.encode(vault)
        try encoder.encode(asset)
        try encoder.encode(durationInDays)
        try encoder.encode(description)
    }

    var encodableValues: [ABIType] { [
        id,
        startTimestamp,
        endTimestamp,
        participantCount,
        totalDeposits,
        vault,
        asset,
        durationInDays,
        description
    ] }
}

extension DripEpochInfo {
    var displayedParticipants: String {
        participantCount.description
    }

    func daysRemaining() -> Int {
        let now = Date()
        let end = endTimestamp.description
        let targetDate = Date(timeIntervalSince1970: Double(end) ?? 0)

        let calendar = Calendar.current
        guard let daysDifference = calendar.dateComponents([.day], from: now, to: targetDate).day else {
            return 0
        }

        return daysDifference
    }

    var totalStakedAmount: String {
        totalDeposits.description.convertBigIntToDecimalFormat(
            decimals: 18,
            decimalPlaces: 1
        )
    }
}
