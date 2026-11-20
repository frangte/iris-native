//
//  CreateInviteCodeUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Issues a fresh invite code the owner can share with a new member.
struct CreateInviteCodeUseCase {
    let repository: ShopRepository

    func execute(for shop: Shop) async throws -> InviteCode {
        try await repository.createInviteCode(forShopID: shop.id)
    }
}
