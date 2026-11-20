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

    /// Issues a new invite code for the shop with `shopID`. Earlier codes stop working.
    func createInviteCode(forShopID shopID: String) async throws -> InviteCode
}
