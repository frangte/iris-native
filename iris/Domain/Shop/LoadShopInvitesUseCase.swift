//
//  LoadShopInvitesUseCase.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Foundation

/// Loads the invite codes that can still be used, newest first.
struct LoadShopInvitesUseCase {
    let repository: ShopRepository

    func execute(for shop: Shop, now: Date = Date()) async throws -> [ShopInvite] {
        try await repository.loadInvites(ofShopID: shop.id)
            .filter { $0.isActive(at: now) }
            .sorted { $0.expiresAt > $1.expiresAt }
    }
}
