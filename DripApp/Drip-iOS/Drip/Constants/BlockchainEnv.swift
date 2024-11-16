//
//  BlockchainEnv.swift
//  Drip
//
//  Created by Shane Chi

import Foundation

enum BlockchainEnv {
    static let polygonRPC = "https://chainlist.org/chain/2442"
    static let polygonChainID = "2442"
    static let mantlePRC = "https://rpc.sepolia.mantle.xyz"
    static let mantleChainID = "5003"
    static let basePRC = "https://sepolia.base.org"
    static let baseChainId = "84532"

    static let chainId: String = BlockchainEnv.baseChainId
    static let rpcURL: String = BlockchainEnv.basePRC
    static let nativeTokenSymbol: String = "ETH"
    static let nativeTokenIcon: String = "token-eth"
}
