//
//  Order.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation

/// A stored order of a shop.
struct Order: Identifiable, Equatable, Hashable {
    let id: String
    /// Human-friendly sequential number shown as "#12".
    let number: Int
    let shopId: Shop.ID
    let createdAt: Date
    let details: OrderDraft
}
