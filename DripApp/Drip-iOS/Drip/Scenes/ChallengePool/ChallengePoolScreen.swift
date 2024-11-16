//
//  ChallengePoolScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import BigInt

struct ChallengePoolScreen: View {
    var onLogOut: (() -> Void)?

    @StateObject private var viewModel: ChallengePoolViewModel

    @State private var isPresentingProfileScreen = false
    @State private var isPresentingCreateChallengeScreen = false
    @State private var isPresentingLeaderBoardScreen = false
    @State private var selectedPoolIndex = 0

    let columns = [GridItem(spacing: 16), GridItem()]
    init(viewModel: ChallengePoolViewModel, onLogOut: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLogOut = onLogOut
    }

    var body: some View {
        VStack(spacing: 20) {
            // navi bar
            HStack(alignment: .center) {
                Image(.naviBarLogo)
                    .resizable()
                    .frame(width: 80, height: 32)
                Spacer()
                Button(action: {
                    isPresentingProfileScreen = true
                }) {
                    Image(.userProfile)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(.black)
            // pool info card
            TabView(selection: $selectedPoolIndex) {
                ForEach(0...1, id: \.self) { index in
                    PoolInfoCard(
                        epochInfo: $viewModel.epochInfo,
                        isActive: selectedPoolIndex == 0 ? .constant(true) : .constant(false)
                    ) {
                        onCardButtonTap()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 1)
                    .tag(index)
                }
            }
            .frame(height: 240)
            .padding(.vertical, 0)
            .padding(.horizontal, 12)
            .background(.clear)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: selectedPoolIndex) {
                if selectedPoolIndex == 0 {
                    DripProfileContract.epochId = BigUInt(1)
                } else {
                    DripProfileContract.epochId = BigUInt(0)
                }
                viewModel.fetchChallenges()
                viewModel.fetchEpochInfo()
            }
            // content
            VStack(spacing: 20) {
                // section header
                HStack {
                    Text("Challenges")
                        .font(.custom("LondrinaSolid-Regular", size: 48))
                        .foregroundStyle(.black)
                    Spacer()
                    Button(action: {
                        isPresentingCreateChallengeScreen = true
                    }) {
                        Image(.createChallenge)
                            .resizable()
                            .frame(width: 48, height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 0)
                // grid view
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16, content: {
                        if viewModel.challenges.isEmpty {
                            Image(.emptyListPlaceholder)
                                .resizable()
                                .frame(width: 164, height: 232)
                        } else {
                            ForEach(viewModel.challenges) { challenge in
                                NavigationLink(destination: {
                                    let viewModel = ChallengeDetailViewModel(challenge: challenge, rpcService: viewModel.rpcService)
                                    ChallengeDetailScreen(viewModel: viewModel)
                                }) {
                                    VStack(spacing: 12) {
                                        challenge.nftImage
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                        VStack (spacing: 4) {
                                            Text(challenge.title)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("\(challenge.displayedStakedAmount) \(DripContracts.dripERC20TokenSymbol) Staked")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundStyle(DripColor.primary500Disabled)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal, 12)

                                    }
                                    .padding(.bottom, 12)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 2))
                                }
                            }

                        }
                    })
                    .padding(.top, 1.5)
                    .padding(.horizontal, 1.5)
                }
            }
            .padding(.init(top: 0, leading: 24, bottom: 1, trailing: 24))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .sheet(isPresented: $isPresentingProfileScreen, onDismiss: {
                viewModel.fetchChallenges()
                viewModel.fetchEpochInfo()
            }) {
                let viewModel = ProfileViewModel(rpcService: viewModel.rpcService)
                ProfileScreen(viewModel: viewModel) {
                    onLogOut?()
                }
            }
            .sheet(isPresented: $isPresentingCreateChallengeScreen, onDismiss: {
                viewModel.fetchChallenges()
                viewModel.fetchEpochInfo()
            }) {
                let viewModel = CreateChallengeViewModel(rpcService: viewModel.rpcService)
                CreateChallengeScreen(viewModel: viewModel)
            }
            .sheet(isPresented: $isPresentingLeaderBoardScreen) {
                Leaderboard()
            }
        }
        .background(DripColor.backgroundMain.ignoresSafeArea())
        .padding(.all, 0)
        .onAppear {
            viewModel.fetchChallenges()
            viewModel.fetchEpochInfo()
        }
    }

    private func onCardButtonTap() {
        if selectedPoolIndex == 0 {
            isPresentingLeaderBoardScreen = true
        } else {
            // claim
        }
    }
}
