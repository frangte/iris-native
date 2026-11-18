//
//  DeleteOrderUseCase.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Permanently removes an order. Cancelling keeps the order; this does not.
struct DeleteOrderUseCase {
    let repository: OrderRepository

    func execute(id: Order.ID) async throws {
        try await repository.deleteOrder(id: id)
    }
}
