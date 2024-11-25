//
//  SetProfileViewModel.swift
//  Drip
//
//  Created by Shane Chi

import Foundation

private enum Constants {
    static let avatarBackgrounds = 0...1
    static let avatarBodies = 0...29
    static let avatarHeads = 0...233
    static let avatarGlasses = 0...20
    static let avatarAccessories = 0...136
}

final class SetProfileViewModel: ObservableObject {

    @Published var isProfileCreated: Bool = false

    @Published var avatarBg = Int.random(in: Constants.avatarBackgrounds)
    @Published var avatarBody = Int.random(in: Constants.avatarBodies)
    @Published var avatarHead = Int.random(in: Constants.avatarHeads)
    @Published var avatarGlasses = Int.random(in: Constants.avatarGlasses)
    @Published var avatarAccessory = Int.random(in: Constants.avatarAccessories)

    let rpcService: RPCService
    let profileContract: DripProfileContract

    init(rpcService: RPCService) {
        self.rpcService = rpcService
        self.profileContract = DripProfileContract(rpcService: rpcService, contractAddress: DripContracts.profile)
    }

    func randomlyGenerateAvatar() {
        avatarBg = Int.random(in: Constants.avatarBackgrounds)
        avatarBody = Int.random(in: Constants.avatarBodies)
        avatarHead = Int.random(in: Constants.avatarHeads)
        avatarGlasses = Int.random(in: Constants.avatarGlasses)
        avatarAccessory = Int.random(in: Constants.avatarAccessories)
    }

    func setProfile(userHandle: String) {
        guard !userHandle.isEmpty else { return }
        Task {
            let isSuccessful = await profileContract.createProfile(
                userHandle: userHandle,
                avatarComponents: [avatarBg, avatarBody, avatarHead, avatarGlasses, avatarAccessory]
            )
            if isSuccessful {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isProfileCreated = true
                }
            }
        }
    }
}
