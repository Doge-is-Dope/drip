//
//  LaunchViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation

final class LaunchViewModel: ObservableObject {

    @Published var isSetUpComplete = false

    private let web3AuthService: Web3AuthService

    init(web3AuthService: Web3AuthService) {
        self.web3AuthService = web3AuthService
    }

    func setUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            Task {
                await self.web3AuthService.setUp()
                self.isSetUpComplete = true
            }
        }
    }
}
