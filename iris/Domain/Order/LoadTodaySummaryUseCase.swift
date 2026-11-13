//
//  LoadTodaySummaryUseCase.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

/// Loads the Today screen summary for a shop.
struct LoadTodaySummaryUseCase {
    let repository: OrderRepository

    func execute(shopId: Shop.ID) async throws -> TodaySummary {
        try await repository.todaySummary(shopId: shopId)
    }
}
