//
//  RPCService.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import web3
import Combine
import BigInt

final class RPCService {
    
    let user: EthereumSingleKeyStorageProtocol?
    let account: EthereumAccount
    var rawAddress: EthereumAddress { account.address }
    var accountAddress: String { rawAddress.asString() }

    let client: EthereumClientProtocol

    private let rpcURL: String
    private let chainId: String
    private var latestBlock = 0

    init?(
        user: EthereumSingleKeyStorageProtocol,
        rpcURL: String,
        chainId: String
    ) {
        self.user = user
        self.rpcURL = rpcURL
        self.chainId = chainId

        do {
            client = EthereumHttpClient(
                url: URL(string: rpcURL)!,
                network: .fromString(chainId)
            )
            account = try EthereumAccount(keyStorage: user)
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func sendTransaction(_ function: ABIFunction, value: BigUInt? = nil) async -> Result<String, Error> {
        do {
            let gasPrice = try await client.eth_gasPrice()
            let estimationTx = try function.transaction(value: value, gasPrice: gasPrice)
            let estimatedGas = try await client.eth_estimateGas(estimationTx)
            let tx = try function.transaction(
                value: value,
                gasPrice: gasPrice,
                gasLimit: estimatedGas.multiplied(by: BigUInt(BigInt(2)))
            )
            let txHash =  try await client.eth_sendRawTransaction(tx, withAccount: account)
            print("Transaction sent: \(txHash)")
            return .success(txHash)
        } catch {
            print("Fail to send tx: \(error)")
            return .failure(error)
        }
    }

    func waitForTxSuccess(txHash: String) async {
        while true {
            do {
                if await checkTxStatus(txHash: txHash) == true {
                    print("tx success: \(txHash)")
                    break
                } else {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
            } catch {
                break
            }
        }
    }

    func checkTxStatus(txHash: String) async -> Bool? {
        do {
            print("check tx status: \(txHash)")
            let receipt = try await client.eth_getTransactionReceipt(txHash: txHash)
            switch receipt.status {
            case .success:
                return true
            case .failure:
                return false
            case .notProcessed:
                return nil
            }
        } catch {
            return nil
        }
    }

    func getTxReceiptLogs(txHash: String) async -> [EthereumLog]? {
        do {
            let receipt = try await client.eth_getTransactionReceipt(txHash: txHash)
            return receipt.logs
        } catch {
            return nil
        }
    }

    func getBalance() async -> BigUInt? {
        let blockChanged = await checkLatestBlockChanged()
        guard blockChanged else { return  nil }
        do {
            let balance = try await client.eth_getBalance(address: rawAddress, block: .Latest)
            print("Native token balance: \(balance)")
            return balance
        } catch {
            return nil
        }
    }

    private func checkLatestBlockChanged() async -> Bool {
        return await withCheckedContinuation({ continuation in
            client.eth_blockNumber { [weak self] result in
                switch result {
                case .success(let val):
                    if self?.latestBlock != val {
                        self?.latestBlock = val
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        })
    }
}
