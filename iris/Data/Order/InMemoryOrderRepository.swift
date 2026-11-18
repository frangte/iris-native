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

    private var orders: [Order]
    private var nextNumber: Int

    init(
        simulatedDelay: Duration = .milliseconds(300),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init,
        orders: [Order] = []
    ) {
        self.simulatedDelay = simulatedDelay
        self.calendar = calendar
        self.now = now
        self.orders = orders
        self.nextNumber = (orders.map(\.number).max() ?? 0) + 1
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        try await Task.sleep(for: simulatedDelay)

        let current = now()
        let today = calendar.startOfDay(for: current)
        // Finished and cancelled orders no longer count towards today's work or money.
        let openOrders = orders.filter { $0.shopId == shopId && $0.status.isOpen }
        let todayCount = openOrders.filter { calendar.isDate($0.details.deliveryDate, inSameDayAs: today) }.count
        let lateCount = openOrders.filter { $0.isLate(at: current, calendar: calendar) }.count
        let remaining = openOrders.reduce(0) { $0 + $1.details.pricing.remaining }

        return TodaySummary(todayCount: todayCount, lateCount: lateCount, remainingAmount: remaining)
    }

    func createOrder(_ draft: OrderDraft, shopId: Shop.ID, by actor: Email) async throws -> Order {
        try await Task.sleep(for: simulatedDelay)

        let timestamp = now()
        let order = Order(
            id: UUID().uuidString,
            number: nextNumber,
            shopId: shopId,
            createdAt: timestamp,
            details: draft,
            status: .new,
            history: [OrderEvent(kind: .created, actor: actor, date: timestamp)]
        )
        nextNumber += 1
        orders.append(order)
        return order
    }

    func order(id: Order.ID) async throws -> Order {
        try await Task.sleep(for: simulatedDelay)

        guard let order = orders.first(where: { $0.id == id }) else { throw OrderError.notFound }
        return order
    }

    func updateStatus(orderId: Order.ID, to status: OrderStatus, by actor: Email) async throws -> Order {
        try await Task.sleep(for: simulatedDelay)

        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { throw OrderError.notFound }
        orders[index].status = status
        orders[index].history.append(OrderEvent(kind: .statusChanged(status), actor: actor, date: now()))
        return orders[index]
    }

    func deleteOrder(id: Order.ID) async throws {
        try await Task.sleep(for: simulatedDelay)

        guard orders.contains(where: { $0.id == id }) else { throw OrderError.notFound }
        orders.removeAll { $0.id == id }
    }
}
