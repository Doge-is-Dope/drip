//
//  ChallengeDetailScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct ChallengeDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var isPresentingQuestScreen = false

    @StateObject private var viewModel: ChallengeDetailViewModel

    init(viewModel: ChallengeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            // navi bar
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(.backWhite)
                        .resizable()
                        .clipped()
                        .frame(width: 22 ,height: 22)
                        .padding(.all, 8)
                })
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(.black)
            
            ScrollView {
                VStack(spacing: 12) {
                    viewModel.challenge.nftImage
                        .resizable()
                        .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 2))
                    HStack {
                        VStack(spacing: 6) {
                            Text(viewModel.challenge.displayDates[0])
                                .font(.system(size: 10))
                                .foregroundStyle(DripColor.primary500Disabled)
                            viewModel.challenge.dailyStatus(index: 0)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        VStack(spacing: 6) {
                            Text(viewModel.challenge.displayDates[1])
                                .font(.system(size: 10))
                                .foregroundStyle(DripColor.primary500Disabled)
                            viewModel.challenge.dailyStatus(index: 1)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        VStack(spacing: 6) {
                            Text(viewModel.challenge.displayDates[2])
                                .font(.system(size: 10))
                                .foregroundStyle(DripColor.primary500Disabled)
                            viewModel.challenge.dailyStatus(index: 2)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        VStack(spacing: 6) {
                            Text(viewModel.challenge.displayDates[3])
                                .font(.system(size: 10))
                                .foregroundStyle(DripColor.primary500Disabled)
                            viewModel.challenge.dailyStatus(index: 3)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        VStack(spacing: 6) {
                            Text(viewModel.challenge.displayDates[4])
                                .font(.system(size: 10))
                                .foregroundStyle(DripColor.primary500Disabled)
                            viewModel.challenge.dailyStatus(index: 4)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.all, 16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 2))
                    VStack(spacing: 4) {
                        Text(viewModel.challenge.title)
                            .font(.custom("LondrinaSolid-Regular", size: 36))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.black)
                        Text("\(viewModel.challenge.displayedStakedAmount) \(DripContracts.dripERC20TokenSymbol) Staked")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer().frame(height: 2)
                        Text(viewModel.challenge.desc)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(DripColor.primary500Disabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 1.5)
                .padding(.top, 1.5)
            }
            .padding(.horizontal, 24)
            ActionButton(title: "Daily Quest") {
                isPresentingQuestScreen = true
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 20)
        .background(DripColor.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isPresentingQuestScreen, onDismiss: {
            viewModel.fetchChallengeDetail()
        }) {
            let viewModel = QuestViewModel(challenge: viewModel.challenge, rpcService: viewModel.rpcService, dayIndex: viewModel.getTodayIndex())
            QuestScreen(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchChallengeDetail()
        }
    }
}

