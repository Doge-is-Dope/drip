//
//  ColorExtension.swift
//  Drip
//
//  Created by Shane Chi 

import SwiftUI

extension Color {
    static func generateRandomColors(count: Int) -> [Color] {
        return (0..<count).map { _ in Color.random() }
    }

    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
