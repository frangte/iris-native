//
//  InMemoryOrderRepository.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation

/// Development stand-in with no orders yet, so the Today screen shows its empty state.
/// Replace with an API-backed repository once the backend is ready.
final class InMemoryOrderRepository: OrderRepository {
    /// Artificial latency so loading states are visible in the UI.
    private let simulatedDelay: Duration

    init(simulatedDelay: Duration = .milliseconds(300)) {
        self.simulatedDelay = simulatedDelay
    }

    func todaySummary(shopId: Shop.ID) async throws -> TodaySummary {
        try await Task.sleep(for: simulatedDelay)
        return .empty
    }
}
