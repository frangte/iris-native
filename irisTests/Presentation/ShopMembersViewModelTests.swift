//
//  ShopMembersViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 20/11/26.
//

import Testing
@testable import iris

@MainActor
struct ShopMembersViewModelTests {
    private final class Sink {
        var copied: String?
    }

    private struct UnexpectedError: Error {}

    private let email = Email("abc@abc.com")!
    private let other = Email("b@b.com")!
    private let shop = Shop(id: "1", name: "Tiệm hoa Mộc", phone: nil, address: nil)
    private let repository = MockShopRepository()
    private let sink: Sink
    private let viewModel: ShopMembersViewModel

    init() {
        let sink = Sink()
        self.sink = sink
        viewModel = ShopMembersViewModel(
            shop: shop,
            email: email,
            members: [ShopMember(email: email, role: .owner)],
            loadMembersUseCase: LoadShopMembersUseCase(repository: repository),
            createInviteCodeUseCase: CreateInviteCodeUseCase(repository: repository),
            copyToPasteboard: { sink.copied = $0 }
        )
    }

    @Test func rowsMarkCurrentUser() async {
        repository.membersResult = .success([
            ShopMember(email: email, role: .owner),
            ShopMember(email: other, role: .manager),
        ])

        await viewModel.load()

        #expect(viewModel.rows.map(\.subtitle) == ["Chủ shop · Bạn", "Quản lý"])
        #expect(viewModel.rows.last?.title == "b@b.com")
    }

    @Test func createInviteCodeShowsCodeAndMessage() async {
        await viewModel.createInviteCode()

        #expect(repository.inviteCodeRequests == ["1"])
        #expect(viewModel.inviteCode?.value == "ABC123")
        #expect(viewModel.inviteMessage?.contains("ABC123") == true)
        #expect(viewModel.inviteMessage?.contains("Tiệm hoa Mộc") == true)
    }

    @Test func createInviteCodeFailureShowsError() async {
        repository.inviteCodeResult = .failure(UnexpectedError())

        await viewModel.createInviteCode()

        #expect(viewModel.inviteCode == nil)
        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
    }

    @Test func copyInviteCodeCopiesValue() async {
        viewModel.copyInviteCode()
        #expect(sink.copied == nil)

        await viewModel.createInviteCode()
        viewModel.copyInviteCode()

        #expect(sink.copied == "ABC123")
        #expect(viewModel.toastMessage == AppStrings.copiedInviteCode)
    }
}
