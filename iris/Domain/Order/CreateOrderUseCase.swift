//
//  CreateOrderUseCase.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Validates the new-order form and stores the order for the shop.
struct CreateOrderUseCase {
    let repository: OrderRepository

    func execute(_ input: OrderInput, shopId: Shop.ID) async throws -> Order {
        let draft = try OrderDraft(input)
        return try await repository.createOrder(draft, shopId: shopId)
    }
}
