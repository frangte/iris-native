//
//  MockShopRepository.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

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
    /// `nil` echoes the draft back as the saved shop.
    var updateError: Error?
    var inviteCodeResult: Result<InviteCode, Error> = .success(InviteCode("ABC123")!)

    func updateShop(id shopID: String, with draft: ShopDraft) async throws -> Shop {
        updatedShops.append((shopID, draft))
        if let updateError { throw updateError }
        return Shop(id: shopID, name: draft.name, phone: draft.phone, address: draft.address)
    }

    var membersResult: Result<[ShopMember], Error> = .success([])

    func loadMembers(ofShopID shopID: String) async throws -> [ShopMember] {
        try membersResult.get()
    }

    func createInviteCode(forShopID shopID: String) async throws -> InviteCode {
        inviteCodeRequests.append(shopID)
        return try inviteCodeResult.get()
    }
}
