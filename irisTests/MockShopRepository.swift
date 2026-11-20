//
//  MockShopRepository.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation
@testable import iris

/// Test double that records calls and returns preconfigured results.
@MainActor
final class MockShopRepository: ShopRepository {
    private(set) var createdDrafts: [(draft: ShopDraft, owner: Email)] = []
    private(set) var joinedCodes: [(code: InviteCode, member: Email)] = []

    var createResult: Result<Shop, Error>
    var joinResult: Result<Shop, Error>

    init(
        createResult: Result<Shop, Error> = .success(Shop(id: "new", name: "New shop", phone: nil, address: nil)),
        joinResult: Result<Shop, Error> = .failure(ShopError.inviteCodeNotFound)
    ) {
        self.createResult = createResult
        self.joinResult = joinResult
    }

    func createShop(_ draft: ShopDraft, owner: Email) async throws -> Shop {
        createdDrafts.append((draft, owner))
        return try createResult.get()
    }

    func joinShop(inviteCode: InviteCode, member: Email) async throws -> Shop {
        joinedCodes.append((inviteCode, member))
        return try joinResult.get()
    }

    private(set) var updatedShops: [(id: String, draft: ShopDraft)] = []
    private(set) var inviteCodeRequests: [String] = []
    private(set) var revokedCodes: [InviteCode] = []
    /// `nil` echoes the draft back as the saved shop.
    var updateError: Error?
    var inviteResult: Result<ShopInvite, Error> = .success(
        ShopInvite(code: InviteCode("ABC123")!, expiresAt: Date(timeIntervalSince1970: 1_795_737_600), useCount: 0)
    )
    var invitesResult: Result<[ShopInvite], Error> = .success([])
    var revokeError: Error?

    func updateShop(id shopID: String, with draft: ShopDraft) async throws -> Shop {
        updatedShops.append((shopID, draft))
        if let updateError { throw updateError }
        return Shop(id: shopID, name: draft.name, phone: draft.phone, address: draft.address)
    }

    var membersResult: Result<[ShopMember], Error> = .success([])

    func loadMembers(ofShopID shopID: String) async throws -> [ShopMember] {
        try membersResult.get()
    }

    func loadInvites(ofShopID shopID: String) async throws -> [ShopInvite] {
        try invitesResult.get()
    }

    func createInvite(forShopID shopID: String) async throws -> ShopInvite {
        inviteCodeRequests.append(shopID)
        return try inviteResult.get()
    }

    func revokeInvite(_ code: InviteCode, inShopID shopID: String) async throws {
        revokedCodes.append(code)
        if let revokeError { throw revokeError }
    }
}
