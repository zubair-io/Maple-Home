//
//  Item.swift
//  Maple Home
//
//  Created by Zubair Lawrence on 3/9/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
