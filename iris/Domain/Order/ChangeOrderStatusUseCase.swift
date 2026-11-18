//
//  ChangeOrderStatusUseCase.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Moves an order to another status, including cancelling it, on behalf of a team member.
struct ChangeOrderStatusUseCase {
    let repository: OrderRepository

    func execute(orderId: Order.ID, to status: OrderStatus, actor: Email) async throws -> Order {
        try await repository.updateStatus(orderId: orderId, to: status, by: actor)
    }
}
