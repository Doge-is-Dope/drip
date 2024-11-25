//
//  Item.swift
//  Drip
//
//  Created by Shane Chi

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
