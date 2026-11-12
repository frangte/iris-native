//
//  Item.swift
//  iris
//
//  Created by SonnyHoang on 11/11/26.
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
