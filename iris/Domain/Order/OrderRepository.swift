//
//  OrderRepository.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

/// Domain boundary for order data. Data layer provides the implementation.
protocol OrderRepository {
    /// Aggregated numbers for the Today screen of the given shop.
    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary

    /// Stores a validated order and returns it with its assigned id and number.
    /// `actor` is recorded as the creator in the order history.
    func createOrder(_ draft: OrderDraft, shopId: Shop.ID, by actor: Email) async throws -> Order

    /// Latest stored state of one order. Throws `OrderError.notFound` when it no longer exists.
    func order(id: Order.ID) async throws -> Order

    /// Moves the order to `status`, records who did it, and returns the updated order.
    func updateStatus(orderId: Order.ID, to status: OrderStatus, by actor: Email) async throws -> Order

    /// Removes the order for good.
    func deleteOrder(id: Order.ID) async throws
}
