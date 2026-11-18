//
//  MockOrderRepository.swift
//  irisTests
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation
@testable import iris

/// Test double that records calls and returns preconfigured results.
@MainActor
final class MockOrderRepository: OrderRepository {
    /// Fixed clock for every recorded event.
    static let epoch = Date(timeIntervalSince1970: 0)

    private(set) var requestedShopIds: [Shop.ID] = []
    private(set) var createdDrafts: [OrderDraft] = []
    private(set) var deletedIds: [Order.ID] = []

    /// Orders visible to `order(id:)`, `updateStatus` and `deleteOrder`. Created orders are added here too.
    var orders: [Order] = []
    var summaryResult: Result<TodaySummary, Error>
    /// When set, `createOrder` throws this instead of returning an order.
    var createError: Error?
    /// When set, `updateStatus` and `deleteOrder` throw this.
    var updateError: Error?

    init(summaryResult: Result<TodaySummary, Error> = .success(.empty)) {
        self.summaryResult = summaryResult
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        requestedShopIds.append(shopId)
        return try summaryResult.get()
    }

    func createOrder(_ draft: OrderDraft, shopId: Shop.ID, by actor: Email) async throws -> Order {
        if let createError { throw createError }
        createdDrafts.append(draft)
        let order = Order(
            id: "order-\(createdDrafts.count)",
            number: createdDrafts.count,
            shopId: shopId,
            createdAt: Self.epoch,
            details: draft,
            history: [OrderEvent(kind: .created, actor: actor, date: Self.epoch)]
        )
        orders.append(order)
        return order
    }

    func order(id: Order.ID) async throws -> Order {
        guard let order = orders.first(where: { $0.id == id }) else { throw OrderError.notFound }
        return order
    }

    func updateStatus(orderId: Order.ID, to status: OrderStatus, by actor: Email) async throws -> Order {
        if let updateError { throw updateError }
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { throw OrderError.notFound }
        orders[index].status = status
        orders[index].history.append(OrderEvent(kind: .statusChanged(status), actor: actor, date: Self.epoch))
        return orders[index]
    }

    func deleteOrder(id: Order.ID) async throws {
        if let updateError { throw updateError }
        guard orders.contains(where: { $0.id == id }) else { throw OrderError.notFound }
        orders.removeAll { $0.id == id }
        deletedIds.append(id)
    }
}
