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
    var status: OrderStatus = .new
    /// What happened to the order and who did it, oldest first.
    var history: [OrderEvent] = []

    /// Moment after which an open order counts as late: the end of its time window,
    /// or midnight after the delivery day when no time was fixed.
    func deadline(calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: details.deliveryDate)
        if let window = details.timeWindow {
            return calendar.date(bySettingHour: window.end.hour, minute: window.end.minute, second: 0, of: day) ?? day
        }
        return calendar.date(byAdding: .day, value: 1, to: day) ?? day
    }

    /// True when the order is still open and its deadline has passed.
    func isLate(at now: Date, calendar: Calendar) -> Bool {
        status.isOpen && now >= deadline(calendar: calendar)
    }
}
