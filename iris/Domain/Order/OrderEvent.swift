//
//  OrderEvent.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation

/// One entry of an order's audit trail: what happened, who did it and when.
struct OrderEvent: Equatable, Hashable {
    enum Kind: Equatable, Hashable {
        case created
        case statusChanged(OrderStatus)
    }

    let kind: Kind
    /// Team member who performed the action.
    let actor: Email
    let date: Date
}
