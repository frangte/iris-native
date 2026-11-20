//
//  LoadShopMembersUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Loads everyone who can work in a shop, owner first.
struct LoadShopMembersUseCase {
    let repository: ShopRepository

    func execute(for shop: Shop) async throws -> [ShopMember] {
        let members = try await repository.loadMembers(ofShopID: shop.id)
        return members.filter { $0.role == .owner } + members.filter { $0.role != .owner }
    }
}
