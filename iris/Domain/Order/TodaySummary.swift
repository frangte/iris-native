//
//  TodaySummary.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

/// Headline numbers for the Today screen: orders due today, overdue orders and money still to collect.
struct TodaySummary: Equatable, Hashable {
    let todayCount: Int
    let lateCount: Int
    /// Outstanding amount across open orders, in VND.
    let remainingAmount: Int

    static let empty = TodaySummary(todayCount: 0, lateCount: 0, remainingAmount: 0)

    /// True when the shop has no order to show on the Today screen.
    var isEmpty: Bool {
        todayCount == 0 && lateCount == 0
    }
}
