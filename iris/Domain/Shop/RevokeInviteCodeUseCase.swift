//
//  RevokeInviteCodeUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Stops an invite code from working before it expires. People who already joined stay in the shop.
struct RevokeInviteCodeUseCase {
    let repository: ShopRepository

    func execute(_ invite: ShopInvite, in shop: Shop) async throws {
        try await repository.revokeInvite(invite.code, inShopID: shop.id)
    }
}
