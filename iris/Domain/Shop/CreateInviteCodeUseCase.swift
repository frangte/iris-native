//
//  CreateInviteCodeUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Issues a fresh invite code the owner can share with new managers.
struct CreateInviteCodeUseCase {
    let repository: ShopRepository

    func execute(for shop: Shop) async throws -> ShopInvite {
        try await repository.createInvite(forShopID: shop.id)
    }
}
