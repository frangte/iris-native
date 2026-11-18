//
//  OrderStatus.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Lifecycle of an order. Display titles live in Presentation.
enum OrderStatus: String, CaseIterable, Hashable {
    /// Just created, nobody has started on it.
    case new
    /// The shop is making the flowers.
    case inProgress
    /// Delivered or picked up.
    case done
    case cancelled

    /// True while the shop still has work to do on the order.
    var isOpen: Bool {
        self == .new || self == .inProgress
    }

    /// Status the "move forward" action leads to. `nil` once the order is finished.
    var next: OrderStatus? {
        switch self {
        case .new: .inProgress
        case .inProgress: .done
        case .done, .cancelled: nil
        }
    }
}
