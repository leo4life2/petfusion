//
//  Item.swift
//  StableDiffusionImages
//
//  Created by Michael Zhu on 12/3/23.
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
