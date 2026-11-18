//
//  LoadOrderUseCase.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Fetches the latest state of one order for the detail screen.
struct LoadOrderUseCase {
    let repository: OrderRepository

    func execute(id: Order.ID) async throws -> Order {
        try await repository.order(id: id)
    }
}
