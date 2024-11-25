//
//  QuestResultScreen.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI

struct QuestResultScreen: View {

    @State private var currentIndex = 0
    private let imgNames = ["quest-done-0", "quest-done-1", "quest-done-2"]

    var body: some View {
        Spacer().frame(height: 96)
        VStack(spacing: 0) {
            Image(imgNames[currentIndex])
                .resizable()
                .frame(width: 220, height: 180)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.85, repeats: true) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % imgNames.count
                        }
                    }
                }
            Spacer().frame(height: 64)
            Text("Ta-da! You’ve finished all the quests!")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.black)
                .frame(height: 72)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 12)
            Text("Come back tomorrow!")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(DripColor.primary500Disabled)
                .frame(height: 24)
            Spacer()
        }
    }
}

#Preview {
    QuestResultScreen()
}
