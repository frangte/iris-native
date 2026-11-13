//
//  OnboardingViewModel.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Observation

/// First screen after login: create a new shop or join an existing one with an invite code.
@Observable
final class OnboardingViewModel {
    /// Which of the two submit actions is currently running.
    enum Action: Equatable {
        case createShop
        case joinShop
    }

    /// Email of the signed-in user, shown in the header.
    let email: Email

    var shopName = "" { didSet { errorMessage = nil } }
    var phone = "" { didSet { errorMessage = nil } }
    var address = "" { didSet { errorMessage = nil } }

    /// Invite code input. Only letters and digits are kept, uppercased and capped at `InviteCode.length`.
    var inviteCode: String {
        get { rawInviteCode }
        set { updateInviteCode(newValue) }
    }
    private var rawInviteCode = ""

    private(set) var activeAction: Action?
    private(set) var errorMessage: String?

    private let createShopUseCase: CreateShopUseCase
    private let joinShopUseCase: JoinShopUseCase
    /// Called with the shop the user created or joined. The owner decides what happens next.
    private let onShopReady: (Shop) -> Void
    private let onLogout: () -> Void

    init(
        email: Email,
        createShopUseCase: CreateShopUseCase,
        joinShopUseCase: JoinShopUseCase,
        onShopReady: @escaping (Shop) -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.email = email
        self.createShopUseCase = createShopUseCase
        self.joinShopUseCase = joinShopUseCase
        self.onShopReady = onShopReady
        self.onLogout = onLogout
    }

    // MARK: - Display data

    var isBusy: Bool { activeAction != nil }

    var canCreateShop: Bool {
        ShopDraft(name: shopName, phone: phone, address: address) != nil
    }

    var canJoinShop: Bool {
        InviteCode(rawInviteCode) != nil
    }

    // MARK: - Actions

    func createShop() async {
        await perform(.createShop) {
            try await createShopUseCase.execute(name: shopName, phone: phone, address: address, owner: email)
        }
    }

    func joinShop() async {
        await perform(.joinShop) {
            try await joinShopUseCase.execute(rawInviteCode: rawInviteCode, member: email)
        }
    }

    func logout() {
        onLogout()
    }

    // MARK: - Private

    /// Runs one submit action with shared loading and error handling.
    private func perform(_ action: Action, _ work: () async throws -> Shop) async {
        guard !isBusy else { return }
        errorMessage = nil
        activeAction = action
        defer { activeAction = nil }

        do {
            let shop = try await work()
            onShopReady(shop)
        } catch let error as ShopError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    private func updateInviteCode(_ newValue: String) {
        errorMessage = nil
        let normalized = newValue
            .filter { $0.isLetter || $0.isNumber }
            .uppercased()
            .prefix(InviteCode.length)
        rawInviteCode = String(normalized)
    }
}
