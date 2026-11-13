//
//  InMemoryShopRepository.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// Development stand-in that keeps shops in memory and accepts one fixed invite code.
/// Replace with an API-backed repository once the backend is ready.
final class InMemoryShopRepository: ShopRepository {
    /// Invite code that always resolves to the sample shop. Matches the placeholder in the UI.
    static let fixedInviteCode = "K7M2QX"

    private var shops: [Shop] = []
    /// Artificial latency so loading states are visible in the UI.
    private let simulatedDelay: Duration

    init(simulatedDelay: Duration = .milliseconds(400)) {
        self.simulatedDelay = simulatedDelay
    }

    func createShop(_ draft: ShopDraft, owner: Email) async throws -> Shop {
        try await Task.sleep(for: simulatedDelay)
        let shop = Shop(id: UUID().uuidString, name: draft.name, phone: draft.phone, address: draft.address)
        shops.append(shop)
        return shop
    }

    func joinShop(inviteCode: InviteCode, member: Email) async throws -> Shop {
        try await Task.sleep(for: simulatedDelay)
        guard inviteCode.value == Self.fixedInviteCode else { throw ShopError.inviteCodeNotFound }
        return Shop(id: "sample-shop", name: AppStrings.shopNamePlaceHolder, phone: nil, address: nil)
    }
}
