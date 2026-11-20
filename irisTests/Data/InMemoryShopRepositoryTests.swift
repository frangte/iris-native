//
//  InMemoryShopRepositoryTests.swift
//  irisTests
//
//  Created by SonnyHoang on 20/11/26.
//

import Foundation
import Testing
@testable import iris

@MainActor
struct InMemoryShopRepositoryTests {
    /// Mutable clock shared with the repository.
    private final class Clock {
        var now = Date(timeIntervalSince1970: 1_795_000_000)
    }

    private let clock = Clock()
    private let repository: InMemoryShopRepository
    private let owner = Email("owner@shop.vn")!
    private let guest = Email("guest@shop.vn")!

    init() {
        let clock = clock
        repository = InMemoryShopRepository(simulatedDelay: .zero, now: { clock.now })
    }

    private func makeShop() async throws -> Shop {
        try await repository.createShop(ShopDraft(name: "ABC", phone: "", address: "")!, owner: owner)
    }

    @Test func newInviteLastsSevenDays() async throws {
        let shop = try await makeShop()

        let invite = try await repository.createInvite(forShopID: shop.id)

        #expect(invite.expiresAt == clock.now.addingTimeInterval(ShopInvite.lifetime))
        #expect(invite.useCount == 0)
    }

    @Test func joiningCountsUseAndAddsManager() async throws {
        let shop = try await makeShop()
        let invite = try await repository.createInvite(forShopID: shop.id)

        let joined = try await repository.joinShop(inviteCode: invite.code, member: guest)

        #expect(joined.id == shop.id)
        let invites = try await repository.loadInvites(ofShopID: shop.id)
        #expect(invites.first?.useCount == 1)
        let members = try await repository.loadMembers(ofShopID: shop.id)
        #expect(members.contains(ShopMember(email: guest, role: .manager)))
    }

    @Test func expiredCodeCannotJoin() async throws {
        let shop = try await makeShop()
        let invite = try await repository.createInvite(forShopID: shop.id)
        clock.now = clock.now.addingTimeInterval(ShopInvite.lifetime + 1)

        await #expect(throws: ShopError.inviteCodeNotFound) {
            try await repository.joinShop(inviteCode: invite.code, member: guest)
        }
    }

    @Test func revokedCodeCannotJoin() async throws {
        let shop = try await makeShop()
        let invite = try await repository.createInvite(forShopID: shop.id)

        try await repository.revokeInvite(invite.code, inShopID: shop.id)

        #expect(try await repository.loadInvites(ofShopID: shop.id).isEmpty)
        await #expect(throws: ShopError.inviteCodeNotFound) {
            try await repository.joinShop(inviteCode: invite.code, member: guest)
        }
    }
}
