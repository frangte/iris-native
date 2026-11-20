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

    /// Replaces the editable details of the shop with `shopID` and returns the updated shop.
    func updateShop(id shopID: String, with draft: ShopDraft) async throws -> Shop

    /// Everyone with access to the shop with `shopID`, in no particular order.
    func loadMembers(ofShopID shopID: String) async throws -> [ShopMember]

    /// Every invite code of the shop with `shopID` that was not revoked, including expired ones.
    func loadInvites(ofShopID shopID: String) async throws -> [ShopInvite]

    /// Issues a new invite code for the shop with `shopID`, valid for `ShopInvite.lifetime`.
    /// Earlier codes keep working.
    func createInvite(forShopID shopID: String) async throws -> ShopInvite

    /// Makes `code` unusable for joining the shop with `shopID`.
    func revokeInvite(_ code: InviteCode, inShopID shopID: String) async throws
}
