//
//  QuestScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct QuestScreen: View {
    @Environment(\.dismiss) var dismiss
    @State var isCompleteDailyQuest = false
    @State var questIndex = 0

    @StateObject private var viewModel: QuestViewModel

    init(viewModel: QuestViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if isCompleteDailyQuest {
                QuestResultScreen()
            } else {
                QuestView(questIndex: .constant(questIndex)) {
                    if questIndex < 2 {
                        questIndex = questIndex + 1
                    } else {
                        isCompleteDailyQuest = true
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundGrey.ignoresSafeArea())
        .onChange(of: isCompleteDailyQuest) {
            if isCompleteDailyQuest {
                viewModel.submitDailyCheck()
            }
        }
        .onChange(of: viewModel.isDailyCheckSubmit) {
            if isCompleteDailyQuest {
                dismiss()
            }
        }
    }
}
