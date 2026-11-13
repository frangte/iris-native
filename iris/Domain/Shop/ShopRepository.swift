//
//  ShopRepository.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Domain boundary for shop persistence. Data layer provides the implementation.
protocol ShopRepository {
    /// Creates a shop owned by `owner` and returns it.
    func createShop(_ draft: ShopDraft, owner: Email) async throws -> Shop

    /// Adds `member` to the shop that issued `inviteCode` and returns that shop.
    func joinShop(inviteCode: InviteCode, member: Email) async throws -> Shop
}
