//
//  Web3Auth+Extension.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import Web3Auth
import web3

extension Web3AuthState: EthereumSingleKeyStorageProtocol {
    public func storePrivateKey(key: Data) throws {

    }

    public func loadPrivateKey() throws -> Data {
        guard let privKeyData = self.privKey?.web3.hexData else {
            throw Web3AuthPrivateKeyError.failToLoadPrivateKey
        }
        return privKeyData

    }

    enum Web3AuthPrivateKeyError: Error {
        case failToLoadPrivateKey
    }
}
