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
    private(set) var requestedShopIds: [Shop.ID] = []
    private(set) var createdDrafts: [OrderDraft] = []

    var summaryResult: Result<TodaySummary, Error>
    /// When set, `createOrder` throws this instead of returning an order.
    var createError: Error?

    init(summaryResult: Result<TodaySummary, Error> = .success(.empty)) {
        self.summaryResult = summaryResult
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        requestedShopIds.append(shopId)
        return try summaryResult.get()
    }

    func createOrder(_ draft: OrderDraft, shopId: Shop.ID) async throws -> Order {
        if let createError { throw createError }
        createdDrafts.append(draft)
        return Order(
            id: "order-\(createdDrafts.count)",
            number: createdDrafts.count,
            shopId: shopId,
            createdAt: Date(timeIntervalSince1970: 0),
            details: draft
        )
    }
}
