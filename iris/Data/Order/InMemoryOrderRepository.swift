//
//  InMemoryOrderRepository.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation

/// Development stand-in that keeps orders in memory for the lifetime of the process.
/// Replace with an API-backed repository once the backend is ready.
final class InMemoryOrderRepository: OrderRepository {
    /// Artificial latency so loading states are visible in the UI.
    private let simulatedDelay: Duration
    private let calendar: Calendar
    private let now: () -> Date

    private var orders: [Order] = []
    private var nextNumber = 1

    init(
        simulatedDelay: Duration = .milliseconds(300),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.simulatedDelay = simulatedDelay
        self.calendar = calendar
        self.now = now
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        try await Task.sleep(for: simulatedDelay)

        let today = calendar.startOfDay(for: now())
        let shopOrders = orders.filter { $0.shopId == shopId }
        let todayCount = shopOrders.filter { calendar.isDate($0.details.deliveryDate, inSameDayAs: today) }.count
        let lateCount = shopOrders.filter { calendar.startOfDay(for: $0.details.deliveryDate) < today }.count
        let remaining = shopOrders.reduce(0) { $0 + $1.details.pricing.remaining }

        return TodaySummary(todayCount: todayCount, lateCount: lateCount, remainingAmount: remaining)
    }

    func createOrder(_ draft: OrderDraft, shopId: Shop.ID) async throws -> Order {
        try await Task.sleep(for: simulatedDelay)

        let order = Order(
            id: UUID().uuidString,
            number: nextNumber,
            shopId: shopId,
            createdAt: now(),
            details: draft
        )
        nextNumber += 1
        orders.append(order)
        return order
    }
}
