//
//  MockOrderRepository.swift
//  irisTests
//
//  Created by SonnyHoang on 13/11/26.
//

@testable import iris

/// Test double that records calls and returns a preconfigured summary.
@MainActor
final class MockOrderRepository: OrderRepository {
    private(set) var requestedShopIds: [Shop.ID] = []

    var summaryResult: Result<TodaySummary, Error>

    init(summaryResult: Result<TodaySummary, Error> = .success(.empty)) {
        self.summaryResult = summaryResult
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        requestedShopIds.append(shopId)
        return try summaryResult.get()
    }
}
