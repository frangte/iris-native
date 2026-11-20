//
//  ShopMembersViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 20/11/26.
//

import Foundation
import Testing
@testable import iris

@MainActor
struct ShopMembersViewModelTests {
    private struct UnexpectedError: Error {}

    private let email = Email("abc@abc.com")!
    private let other = Email("b@b.com")!
    private let shop = Shop(id: "1", name: "ABC", phone: nil, address: nil)
    private let repository = MockShopRepository()
    private let viewModel: ShopMembersViewModel

    init() {
        viewModel = ShopMembersViewModel(
            shop: shop,
            email: email,
            members: [ShopMember(email: email, role: .owner)],
            loadMembersUseCase: LoadShopMembersUseCase(repository: repository),
            loadInvitesUseCase: LoadShopInvitesUseCase(repository: repository),
            createInviteCodeUseCase: CreateInviteCodeUseCase(repository: repository),
            revokeInviteCodeUseCase: RevokeInviteCodeUseCase(repository: repository)
        )
    }

    private func invite(_ code: String, daysFromNow days: Double, uses: Int = 0) -> ShopInvite {
        ShopInvite(code: InviteCode(code)!, expiresAt: Date().addingTimeInterval(days * 86_400), useCount: uses)
    }

    @Test func titleAndRowsMarkCurrentUser() async {
        repository.membersResult = .success([
            ShopMember(email: other, role: .manager),
            ShopMember(email: email, role: .owner),
        ])

        await viewModel.load()

        #expect(viewModel.membersTitle == "2 người trong ABC")
        #expect(viewModel.rows.map(\.title) == ["abc@abc.com (bạn)", "b@b.com"])
        #expect(viewModel.rows.map(\.subtitle) == ["Chủ shop", "Quản lý"])
    }

    @Test func loadShowsOnlyActiveInvites() async {
        repository.membersResult = .success([ShopMember(email: email, role: .owner)])
        repository.invitesResult = .success([invite("AAAAAA", daysFromNow: -1), invite("BBBBBB", daysFromNow: 3, uses: 2)])

        await viewModel.load()

        #expect(viewModel.inviteCards.map(\.code) == ["BBBBBB"])
        #expect(viewModel.inviteCards.first?.detail.hasSuffix("· đã dùng 2 lần") == true)
    }

    @Test func createInviteCodeShowsCard() async {
        await viewModel.createInviteCode()

        let card = viewModel.inviteCards.first
        #expect(repository.inviteCodeRequests == ["1"])
        #expect(card?.code == "ABC123")
        #expect(card?.detail.hasPrefix("Hết hạn ") == true)
        #expect(card?.shareMessage.contains("ABC123") == true)
        #expect(card?.shareMessage.contains("ABC") == true)
    }

    @Test func createInviteCodeFailureShowsError() async {
        repository.inviteResult = .failure(UnexpectedError())

        await viewModel.createInviteCode()

        #expect(viewModel.inviteCards.isEmpty)
        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
    }

    @Test func revokeAsksThenRemovesCode() async throws {
        await viewModel.createInviteCode()

        viewModel.requestRevoke(id: "ABC123")
        #expect(viewModel.revokeConfirmTitle == "Thu hồi mã ABC123?")
        #expect(repository.revokedCodes.isEmpty)
        let invite = try #require(viewModel.pendingRevoke)

        // The alert clears the pending invite when it closes, before the button action runs.
        viewModel.pendingRevoke = nil
        await viewModel.confirmRevoke(invite)

        #expect(repository.revokedCodes.map(\.value) == ["ABC123"])
        #expect(viewModel.inviteCards.isEmpty)
        #expect(viewModel.pendingRevoke == nil)
    }

    @Test func dismissingConfirmationKeepsCode() async {
        await viewModel.createInviteCode()
        viewModel.requestRevoke(id: "ABC123")

        viewModel.pendingRevoke = nil

        #expect(repository.revokedCodes.isEmpty)
        #expect(viewModel.inviteCards.count == 1)
    }

    @Test func revokeFailureKeepsCode() async throws {
        repository.revokeError = UnexpectedError()
        await viewModel.createInviteCode()
        viewModel.requestRevoke(id: "ABC123")
        let invite = try #require(viewModel.pendingRevoke)

        await viewModel.confirmRevoke(invite)

        #expect(viewModel.inviteCards.count == 1)
        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
    }
}
