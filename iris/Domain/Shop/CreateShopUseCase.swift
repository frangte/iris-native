//
//  CreateShopUseCase.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Validates the shop form and creates the shop for the signed-in owner.
struct CreateShopUseCase {
    let repository: ShopRepository

    func execute(name: String, phone: String, address: String, owner: Email) async throws -> Shop {
        guard let draft = ShopDraft(name: name, phone: phone, address: address) else {
            throw ShopError.emptyName
        }
        return try await repository.createShop(draft, owner: owner)
    }
}
