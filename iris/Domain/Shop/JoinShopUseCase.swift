//
//  JoinShopUseCase.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Validates the invite code and joins the matching shop.
struct JoinShopUseCase {
    let repository: ShopRepository

    func execute(rawInviteCode: String, member: Email) async throws -> Shop {
        guard let inviteCode = InviteCode(rawInviteCode) else { throw ShopError.invalidInviteCode }
        return try await repository.joinShop(inviteCode: inviteCode, member: member)
    }
}
