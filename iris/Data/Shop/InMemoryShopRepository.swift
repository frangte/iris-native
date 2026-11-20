//
//  InMemoryShopRepository.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// Development stand-in that keeps shops and their members in memory.
/// Joining accepts the fixed sample code or any unexpired code issued by `createInvite`.
/// Replace with an API-backed repository once the backend is ready.
final class InMemoryShopRepository: ShopRepository {
    /// Invite code that always resolves to the sample shop. Matches the placeholder in the UI.
    static let fixedInviteCode = "K7M2QX"

    private var shops: [Shop] = []
    /// Members per shop ID.
    private var members: [String: [ShopMember]] = [:]
    /// Invites that were not revoked, per shop ID.
    private var invites: [String: [ShopInvite]] = [:]
    /// Artificial latency so loading states are visible in the UI.
    private let simulatedDelay: Duration

    /// Injected clock so expiry is testable.
    private let now: () -> Date

    init(simulatedDelay: Duration = .milliseconds(400), now: @escaping () -> Date = Date.init) {
        self.simulatedDelay = simulatedDelay
        self.now = now
    }

    func createShop(_ draft: ShopDraft, owner: Email) async throws -> Shop {
        try await Task.sleep(for: simulatedDelay)
        let shop = Shop(id: UUID().uuidString, name: draft.name, phone: draft.phone, address: draft.address)
        shops.append(shop)
        members[shop.id] = [ShopMember(email: owner, role: .owner)]
        return shop
    }

    func joinShop(inviteCode: InviteCode, member: Email) async throws -> Shop {
        try await Task.sleep(for: simulatedDelay)
        let shop: Shop
        if let shopID = activeShopID(for: inviteCode),
           let issuer = shops.first(where: { $0.id == shopID }) {
            shop = issuer
            countUse(of: inviteCode, in: shopID)
        } else if inviteCode.value == Self.fixedInviteCode {
            shop = sampleShop()
        } else {
            throw ShopError.inviteCodeNotFound
        }
        addMember(member, to: shop.id)
        return shop
    }

    func updateShop(id shopID: String, with draft: ShopDraft) async throws -> Shop {
        try await Task.sleep(for: simulatedDelay)
        let updated = Shop(id: shopID, name: draft.name, phone: draft.phone, address: draft.address)
        if let index = shops.firstIndex(where: { $0.id == shopID }) {
            shops[index] = updated
        } else {
            shops.append(updated)
        }
        return updated
    }

    func loadMembers(ofShopID shopID: String) async throws -> [ShopMember] {
        try await Task.sleep(for: simulatedDelay)
        return members[shopID] ?? []
    }

    func loadInvites(ofShopID shopID: String) async throws -> [ShopInvite] {
        try await Task.sleep(for: simulatedDelay)
        return invites[shopID] ?? []
    }

    func createInvite(forShopID shopID: String) async throws -> ShopInvite {
        try await Task.sleep(for: simulatedDelay)
        // Unambiguous characters only, so the code is easy to read aloud and type.
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let candidate = String((0..<InviteCode.length).compactMap { _ in alphabet.randomElement() })
        guard let code = InviteCode(candidate) else { throw ShopError.invalidInviteCode }

        let invite = ShopInvite(code: code, expiresAt: now().addingTimeInterval(ShopInvite.lifetime), useCount: 0)
        invites[shopID, default: []].append(invite)
        return invite
    }

    func revokeInvite(_ code: InviteCode, inShopID shopID: String) async throws {
        try await Task.sleep(for: simulatedDelay)
        invites[shopID]?.removeAll { $0.code == code }
    }

    // MARK: - Private

    /// Shop behind the fixed invite code, created with a sample owner on first use.
    private func sampleShop() -> Shop {
        let id = "sample-shop"
        if let existing = shops.first(where: { $0.id == id }) { return existing }

        let shop = Shop(id: id, name: AppStrings.shopNamePlaceHolder, phone: nil, address: nil)
        shops.append(shop)
        if let owner = Email("chu@tiemhoamoc.vn") {
            members[id] = [ShopMember(email: owner, role: .owner)]
        }
        return shop
    }

    /// Shop that issued `code`, if the code is still valid.
    private func activeShopID(for code: InviteCode) -> String? {
        let date = now()
        return invites.first { _, list in
            list.contains { $0.code == code && $0.isActive(at: date) }
        }?.key
    }

    private func countUse(of code: InviteCode, in shopID: String) {
        guard let index = invites[shopID]?.firstIndex(where: { $0.code == code }),
              let invite = invites[shopID]?[index] else { return }
        invites[shopID]?[index] = ShopInvite(code: invite.code, expiresAt: invite.expiresAt, useCount: invite.useCount + 1)
    }

    private func addMember(_ email: Email, to shopID: String) {
        var list = members[shopID] ?? []
        guard !list.contains(where: { $0.email == email }) else { return }
        list.append(ShopMember(email: email, role: .manager))
        members[shopID] = list
    }
}
