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
    func createOrder(_ draft: OrderDraft, shopId: Shop.ID) async throws -> Order
}
