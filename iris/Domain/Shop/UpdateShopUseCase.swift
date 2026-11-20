//
//  UpdateShopUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Validates the edited shop details and saves them.
struct UpdateShopUseCase {
    let repository: ShopRepository

    func execute(shop: Shop, name: String, phone: String, address: String) async throws -> Shop {
        guard let draft = ShopDraft(name: name, phone: phone, address: address) else {
            throw ShopError.emptyName
        }
        return try await repository.updateShop(id: shop.id, with: draft)
    }
}
