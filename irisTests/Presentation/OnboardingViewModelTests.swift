//
//  OnboardingViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

import Testing
@testable import iris

@MainActor
struct OnboardingViewModelTests {
    /// Captures the callbacks the view model fires.
    private final class Sink {
        var shop: Shop?
        var didLogout = false
    }

    private let email = Email("abc@abc.com")!
    private let repository = MockShopRepository()
    private let sink: Sink
    private let viewModel: OnboardingViewModel

    init() {
        // Capture a local reference so the escaping closures do not capture `self` mid-initialization.
        let sink = Sink()
        self.sink = sink
        viewModel = OnboardingViewModel(
            email: email,
            createShopUseCase: CreateShopUseCase(repository: repository),
            joinShopUseCase: JoinShopUseCase(repository: repository),
            onShopReady: { sink.shop = $0 },
            onLogout: { sink.didLogout = true }
        )
    }

    @Test func startsEmptyAndIdle() {
        #expect(viewModel.email == email)
        #expect(viewModel.canCreateShop == false)
        #expect(viewModel.canJoinShop == false)
        #expect(viewModel.isBusy == false)
    }

    @Test func createShopRequiresName() async {
        viewModel.shopName = "   "
        await viewModel.createShop()

        #expect(viewModel.errorMessage == AppStrings.shopNameRequired)
        #expect(repository.createdDrafts.isEmpty)
        #expect(sink.shop == nil)
    }

    @Test func createShopTrimsAndReportsShop() async {
        let created = Shop(id: "1", name: "Tiệm hoa Mộc", phone: "0900", address: nil)
        repository.createResult = .success(created)
        viewModel.shopName = " Tiệm hoa Mộc "
        viewModel.phone = "0900"
        viewModel.address = ""
        #expect(viewModel.canCreateShop)

        await viewModel.createShop()

        let draft = repository.createdDrafts.first?.draft
        #expect(draft?.name == "Tiệm hoa Mộc")
        #expect(draft?.phone == "0900")
        #expect(draft?.address == nil)
        #expect(repository.createdDrafts.first?.owner == email)
        #expect(sink.shop == created)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func inviteCodeIsNormalized() {
        viewModel.inviteCode = " k7m-2qx99 "

        #expect(viewModel.inviteCode == "K7M2QX")
        #expect(viewModel.canJoinShop)
    }

    @Test func shortInviteCodeShowsError() async {
        viewModel.inviteCode = "K7M"
        await viewModel.joinShop()

        #expect(viewModel.errorMessage == AppStrings.invalidInvitationCode)
        #expect(repository.joinedCodes.isEmpty)
    }

    @Test func unknownInviteCodeShowsError() async {
        repository.joinResult = .failure(ShopError.inviteCodeNotFound)
        viewModel.inviteCode = "AAAAAA"

        await viewModel.joinShop()

        #expect(viewModel.errorMessage == AppStrings.invitationCodeNotFound)
        #expect(sink.shop == nil)
    }

    @Test func knownInviteCodeReportsShop() async {
        let joined = Shop(id: "2", name: "Joined", phone: nil, address: nil)
        repository.joinResult = .success(joined)
        viewModel.inviteCode = "K7M2QX"

        await viewModel.joinShop()

        #expect(repository.joinedCodes.first?.code.value == "K7M2QX")
        #expect(repository.joinedCodes.first?.member == email)
        #expect(sink.shop == joined)
    }

    @Test func typingClearsError() async {
        viewModel.inviteCode = "K7M"
        await viewModel.joinShop()
        #expect(viewModel.errorMessage != nil)

        viewModel.shopName = "A"

        #expect(viewModel.errorMessage == nil)
    }

    @Test func logoutFiresCallback() {
        viewModel.logout()

        #expect(sink.didLogout)
    }
}
