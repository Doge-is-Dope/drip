//
//  DripERC20Contract.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import BigInt

final class DripERC20Contract {
    private let rpcService: RPCService
    private let contractAddress: EthereumAddress
    private lazy var erc20: ERC20 = ERC20(client: rpcService.client)

    init(rpcService: RPCService, contractAddress: String) {
        self.rpcService = rpcService
        self.contractAddress = EthereumAddress(contractAddress)
    }

    func approveTransfer(
        spender: EthereumAddress = EthereumAddress(DripContracts.challenge),
        amount: BigUInt
    ) async -> Bool {
        let function = ERC20Functions.approve(
            contract: contractAddress,
            from: rpcService.rawAddress,
            spender: spender,
            value: amount
        )
        let result = await rpcService.sendTransaction(function)
        switch result {
        case let .success(txHash):
            await rpcService.waitForTxSuccess(txHash: txHash)
            return true
        case let .failure(error):
            print("Fail to create profile: \(error)")
            return false
        }
    }

    func getBalance() async -> String? {
        let bal = try? await erc20.balanceOf(tokenContract: contractAddress, address: rpcService.rawAddress)
        guard let bal else { return nil }
        return bal.description.convertBigIntToDecimalFormat(decimals: 18, decimalPlaces: 6)
    }
}
