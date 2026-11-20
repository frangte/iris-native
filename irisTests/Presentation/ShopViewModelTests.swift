//
//  ShopViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 20/11/26.
//

import Testing
@testable import iris

@MainActor
struct ShopViewModelTests {
    /// Captures the callbacks the view model fires.
    private final class Sink {
        var shops: [Shop] = []
        var displayNames: [String] = []
        var didLogout = false
    }

    private let email = Email("abc@abc.com")!
    private let shop = Shop(id: "1", name: "Tiệm hoa Mộc", phone: "0909", address: nil)
    private let repository = MockShopRepository()
    private let sink: Sink
    private let viewModel: ShopViewModel

    init() {
        // Capture a local reference so the escaping closures do not capture `self` mid-initialization.
        let sink = Sink()
        self.sink = sink
        viewModel = ShopViewModel(
            shop: shop,
            email: email,
            displayName: "",
            loadMembersUseCase: LoadShopMembersUseCase(repository: repository),
            updateShopUseCase: UpdateShopUseCase(repository: repository),
            createInviteCodeUseCase: CreateInviteCodeUseCase(repository: repository),
            createShopUseCase: CreateShopUseCase(repository: repository),
            joinShopUseCase: JoinShopUseCase(repository: repository),
            onShopChanged: { sink.shops.append($0) },
            onDisplayNameChanged: { sink.displayNames.append($0) },
            onLogout: { sink.didLogout = true }
        )
    }

    @Test func headerWaitsForMembers() {
        #expect(viewModel.roleTitle == nil)
        #expect(viewModel.memberCountText == nil)
        #expect(viewModel.buildLine == "Floied · bản thử nghiệm")
    }

    @Test func loadShowsRoleAndMemberCount() async {
        let other = Email("b@b.com")!
        repository.membersResult = .success([
            ShopMember(email: other, role: .manager),
            ShopMember(email: email, role: .owner),
        ])

        await viewModel.load()

        #expect(viewModel.members.first?.role == .owner)
        #expect(viewModel.roleTitle == AppStrings.owner)
        #expect(viewModel.memberCountText == "2 người")
    }

    @Test func inviteCodeIsNormalized() {
        viewModel.inviteCode = " k7m-2qx99 "

        #expect(viewModel.inviteCode == "K7M2QX")
        #expect(viewModel.canJoinShop)
    }

    @Test func joinShopSwitchesShopAndClearsCode() async {
        let joined = Shop(id: "2", name: "Hoa Xinh", phone: nil, address: nil)
        repository.joinResult = .success(joined)
        viewModel.inviteCode = "K7M2QX"

        await viewModel.joinShop()

        #expect(repository.joinedCodes.first?.member == email)
        #expect(sink.shops == [joined])
        #expect(viewModel.inviteCode == "")
    }

    @Test func unknownInviteCodeShowsError() async {
        viewModel.inviteCode = "AAAAAA"

        await viewModel.joinShop()

        #expect(viewModel.errorMessage == AppStrings.invitationCodeNotFound)
        #expect(sink.shops.isEmpty)
    }

    @Test func editingDisplayNameReportsIt() {
        viewModel.displayName = "Lan"

        #expect(sink.displayNames == ["Lan"])
    }

    @Test func savingShopInfoUpdatesHeaderAndPops() async {
        viewModel.path = [.info]
        let info = viewModel.makeShopInfoViewModel()
        info.name = "Hoa Xinh"

        await info.save()

        #expect(viewModel.shop.name == "Hoa Xinh")
        #expect(sink.shops.first?.name == "Hoa Xinh")
        #expect(viewModel.path.isEmpty)
    }

    @Test func creatingShopClosesSheetAndSwitchesShop() async {
        let created = Shop(id: "3", name: "Shop 2", phone: nil, address: nil)
        repository.createResult = .success(created)
        viewModel.openNewShop()
        #expect(viewModel.isCreatingShop)

        let newShop = viewModel.makeNewShopViewModel()
        newShop.name = "Shop 2"
        await newShop.create()

        #expect(viewModel.isCreatingShop == false)
        #expect(sink.shops == [created])
        #expect(repository.createdDrafts.first?.owner == email)
    }

    @Test func cancellingNewShopClosesSheet() {
        viewModel.openNewShop()
        viewModel.makeNewShopViewModel().cancel()

        #expect(viewModel.isCreatingShop == false)
    }

    @Test func logoutAsksFirst() {
        viewModel.requestLogout()
        #expect(viewModel.isConfirmingLogout)
        #expect(sink.didLogout == false)

        viewModel.logout()

        #expect(sink.didLogout)
    }
}
