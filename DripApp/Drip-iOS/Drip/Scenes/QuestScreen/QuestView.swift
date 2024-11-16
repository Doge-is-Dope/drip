//
//  QuestView.swift
//  Drip
//
//  Created by Shane Chi

import SwiftUI
import CoreGraphics

struct QuestView: View {

    @State private var timeRemaining: CGFloat = 10.0
    let totalTime: CGFloat = 10.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @Binding var questIndex: Int
    var onComplete: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                Text("Question \(questIndex + 1) / 3")
                    .font(.custom("LondrinaSolid-Regular", size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                Image(.clock)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("\(String(format: "%.1f", timeRemaining)) s")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 55)
                    .foregroundStyle(DripColor.primary500Primary)
            }
            Spacer().frame(height: 16)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width)
                        .foregroundColor(DripColor.primary500Primary)
                    Rectangle()
                        .frame(width: (1 - (timeRemaining / totalTime)) * geometry.size.width)
                        .foregroundColor(Color.init(red: 176/255, green: 220/255, blue: 255/255))
                        .animation(.linear(duration: 1), value: timeRemaining)
                }
            }
            .frame(height: 5)
            .clipShape(RoundedRectangle(cornerRadius: 2.5))

            Spacer().frame(height: 20)
            Text(currentQuestion())
                .font(.system(size: 30, weight: .bold))
                .frame(alignment: .top)
                .minimumScaleFactor(0.5)
                .fixedSize(horizontal: false, vertical: false)
                .frame(maxHeight: 200)
            Spacer().frame(height: 20)

            VStack(spacing: 16) {
                StokeButton(title: currentAnswers()[0]) {
                    onComplete?()
                }
                StokeButton(title: currentAnswers()[1]) {
                    onComplete?()
                }
                StokeButton(title: currentAnswers()[2]) {
                    onComplete?()
                }
                StokeButton(title: currentAnswers()[3]){
                    onComplete?()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DripColor.backgroundGrey.ignoresSafeArea())
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            }
        }
        .onChange(of: questIndex) {
            timeRemaining = totalTime
        }
    }

     func currentQuestion() -> AttributedString {
         let questions = [
             ("The earthquake was a terrible catastrophe.", "catastrophe"),
             ("He took out the binoculars and adjusted the focus.", "binoculars"),
             ("Americans are called to enact this promise in our lives and in our laws.", "enact")
         ]

         let (sentence, word) = questions[questIndex % questions.count]
         return highlightWord(in: sentence, word: word)
     }

     func currentAnswers() -> [String] {
         let answers = [
             ["地窖、地下室", "原因、起因", "大災難", "家務雜物"],
             ["按鈕", "登機卡", "後車箱", "雙筒望遠鏡"],
             ["制定法律", "約定", "教導", "處置"]
         ]
         return answers[questIndex % answers.count]
     }

    func highlightWord(in sentence: String, word: String) -> AttributedString {
         let textColor = UIColor.black
         let range = (sentence.lowercased() as NSString).range(of: word.lowercased())
         let mutableAttributedString = NSMutableAttributedString(string: sentence)
         mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: sentence.count))
         mutableAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 57/255, green: 167/255, blue: 255/255, alpha: 1), range: range)
         return AttributedString(mutableAttributedString)
     }


    func sampleQuestion_0() -> AttributedString {
        let sentence = "The earthquake was a terrible catastrophe."
        let word = "catastrophe"

        let textColor = UIColor.black

        let range = (sentence.lowercased() as NSString).range(of: word.lowercased())
        let mutableAttributedString = NSMutableAttributedString.init(string: sentence)
        mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: sentence.count))
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 57/255, green: 167/255, blue: 255/255, alpha: 1), range: range)

        return AttributedString(mutableAttributedString)
    }

    func sampleAnswers_0() -> [String] {
        return ["地窖、地下室", "原因、起因", "大災難", "家務雜物"]
    }

    func sampleQuestion_1() -> AttributedString {
        let sentence = "He took out the binoculars and adjusted the focus."
        let word = "binoculars"

        let textColor = UIColor.black

        let range = (sentence.lowercased() as NSString).range(of: word.lowercased())
        let mutableAttributedString = NSMutableAttributedString.init(string: sentence)
        mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: sentence.count))
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 57/255, green: 167/255, blue: 255/255, alpha: 1), range: range)

        return AttributedString(mutableAttributedString)
    }

    func sampleAnswers_1() -> [String] {
        return ["按鈕", "登機卡", "後車箱", "雙筒望遠鏡"]
    }

    func sampleQuestion_2() -> AttributedString {
        let sentence = "Americans are called to enact this promise in our lives and in our laws."
        let word = "enact"

        let textColor = UIColor.black

        let range = (sentence.lowercased() as NSString).range(of: word.lowercased())
        let mutableAttributedString = NSMutableAttributedString.init(string: sentence)
        mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: sentence.count))
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor(red: 57/255, green: 167/255, blue: 255/255, alpha: 1), range: range)

        return AttributedString(mutableAttributedString)
    }

    func sampleAnswers_2() -> [String] {
        return ["制定法律", "約定", "教導", "處置"]
    }
}
