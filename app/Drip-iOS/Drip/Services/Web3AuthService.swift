//
//  Web3AuthService.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import Web3Auth
import Combine

final class Web3AuthService {
    let logInSuccessSubject = PassthroughSubject<Void, Never>()

    var web3Auth: Web3Auth?
    var user: Web3AuthState?

    static let CLIENT_ID = "BAACJ2aWXi3X4WYK2m6xGdsFmwGGMOrE3dol-d5gFsBndARHq_CaSteEs3X28JYYZ-IZ039ZOyQZ0kxOpWKcsiE"
    private let network: Network = .sapphire_devnet

    func setUp() async {
        guard web3Auth == nil else { return }

        do {
            web3Auth = try await Web3Auth(W3AInitParams(
                clientId: Web3AuthService.CLIENT_ID,
                network: network,
                redirectUrl: "com.yuhsuan.Drip://auth"
            ))

            if let state = web3Auth?.state {
                user = state
                logInSuccessSubject.send(())
            }
        } catch {
            print("Something went wrong")
        }
    }

    func login(with email: String) async {
        do {
            let result = try await web3Auth?.login(
                W3ALoginParams(
                    loginProvider: .EMAIL_PASSWORDLESS,
                    extraLoginOptions: ExtraLoginOptions(login_hint: email)
                ))
            user = result
            logInSuccessSubject.send(())
        } catch {
            print("Fail to login: \(error)")
        }
    }

    func logOut() async -> Bool{
        do {
            try await web3Auth?.logout()
            return true
        } catch {
            print("Fail to logout: \(error)")
            return false
        }
    }
}
