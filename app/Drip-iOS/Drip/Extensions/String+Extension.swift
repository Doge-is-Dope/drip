//
//  StringExtension.swift
//  Drip
//
//  Created by Shane Chi

import Foundation

extension String {
    func convertBigIntToDecimalFormat(decimals: Int, decimalPlaces: Int) -> String {
        guard !self.isEmpty, self.allSatisfy({ $0.isNumber }) else {
            return "Invalid input"
        }

        var numberString = self

        if numberString.count < decimals {
            let zerosToAdd = decimals - numberString.count
            numberString = String(repeating: "0", count: zerosToAdd) + numberString
        }

        let integerPart = numberString.count > decimals ? String(numberString.prefix(numberString.count - decimals)) : "0"
        let fractionalPart = String(numberString.suffix(decimals))

        var result = integerPart + "." + fractionalPart

        if decimalPlaces < decimals {
            let endIndex = result.index(result.startIndex, offsetBy: integerPart.count + 1 + decimalPlaces)
            result = String(result[result.startIndex..<endIndex])
        }

        result = result.trimmingCharacters(in: CharacterSet(charactersIn: "0"))

        if result.hasPrefix(".") {
            result = "0" + result
        }
        return result.hasSuffix(".") ? String(result.dropLast()) : result
    }
}
