//
//  ShopMembersViewModel.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Observation
import UIKit

/// Members screen: everyone in the shop, and an invite code to bring in someone new.
@Observable
final class ShopMembersViewModel {
    /// One line in the member list. The view renders these without knowing about roles.
    struct MemberRow: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String
    }

    private(set) var members: [ShopMember]
    /// Latest code issued on this screen. `nil` until the user creates one.
    private(set) var inviteCode: InviteCode?
    private(set) var isCreatingCode = false
    private(set) var errorMessage: String?
    private(set) var toastMessage: String?

    private let shop: Shop
    private let email: Email
    private let loadMembersUseCase: LoadShopMembersUseCase
    private let createInviteCodeUseCase: CreateInviteCodeUseCase
    private let copyToPasteboard: (String) -> Void
    private var toastTask: Task<Void, Never>?

    init(
        shop: Shop,
        email: Email,
        members: [ShopMember],
        loadMembersUseCase: LoadShopMembersUseCase,
        createInviteCodeUseCase: CreateInviteCodeUseCase,
        copyToPasteboard: @escaping (String) -> Void = { UIPasteboard.general.string = $0 }
    ) {
        self.shop = shop
        self.email = email
        self.members = members
        self.loadMembersUseCase = loadMembersUseCase
        self.createInviteCodeUseCase = createInviteCodeUseCase
        self.copyToPasteboard = copyToPasteboard
    }

    // MARK: - Display data

    /// "abc@abc.com" / "Chủ shop · Bạn"
    var rows: [MemberRow] {
        members.map { member in
            let isCurrentUser = member.email == email
            let subtitle = isCurrentUser ? "\(member.role.title) · \(AppStrings.you)" : member.role.title
            return MemberRow(id: member.id, title: member.email.value, subtitle: subtitle)
        }
    }

    /// Ready-to-send text for the share sheet.
    var inviteMessage: String? {
        guard let inviteCode else { return nil }
        return "\(AppStrings.inviteMessagePrefix) \(shop.name) \(AppStrings.inviteMessageOn) \(AppStrings.appName). \(AppStrings.inviteMessageCode) \(inviteCode.value)"
    }

    // MARK: - Actions

    func load() async {
        do {
            members = try await loadMembersUseCase.execute(for: shop)
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func createInviteCode() async {
        guard !isCreatingCode else { return }
        errorMessage = nil
        isCreatingCode = true
        defer { isCreatingCode = false }

        do {
            inviteCode = try await createInviteCodeUseCase.execute(for: shop)
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func copyInviteCode() {
        guard let inviteCode else { return }
        copyToPasteboard(inviteCode.value)
        showToast(AppStrings.copiedInviteCode)
    }

    // MARK: - Private

    private func showToast(_ message: String) {
        toastMessage = message
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.toastMessage = nil
        }
    }
}
