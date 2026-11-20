//
//  ShopMembersViewModel.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Foundation
import Observation

/// Members screen: everyone in the shop, and the invite codes that let new managers join.
@Observable
final class ShopMembersViewModel {
    /// One line in the member list. The view renders these without knowing about roles.
    struct MemberRow: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String
    }

    /// One active invite code with its display text.
    struct InviteCard: Identifiable, Equatable {
        let id: String
        let code: String
        /// "Hết hạn 27/11 · đã dùng 0 lần"
        let detail: String
        /// Ready-to-send text for the share sheet.
        let shareMessage: String
    }

    private(set) var members: [ShopMember]
    private(set) var invites: [ShopInvite] = []
    private(set) var isCreatingCode = false
    /// Code currently being revoked, so its button can show progress.
    private(set) var revokingCode: InviteCode?
    private(set) var errorMessage: String?
    /// Invite waiting for the user to confirm revocation. Drives the alert.
    var pendingRevoke: ShopInvite?

    private let shop: Shop
    private let email: Email
    private let loadMembersUseCase: LoadShopMembersUseCase
    private let loadInvitesUseCase: LoadShopInvitesUseCase
    private let createInviteCodeUseCase: CreateInviteCodeUseCase
    private let revokeInviteCodeUseCase: RevokeInviteCodeUseCase

    init(
        shop: Shop,
        email: Email,
        members: [ShopMember],
        loadMembersUseCase: LoadShopMembersUseCase,
        loadInvitesUseCase: LoadShopInvitesUseCase,
        createInviteCodeUseCase: CreateInviteCodeUseCase,
        revokeInviteCodeUseCase: RevokeInviteCodeUseCase
    ) {
        self.shop = shop
        self.email = email
        self.members = members
        self.loadMembersUseCase = loadMembersUseCase
        self.loadInvitesUseCase = loadInvitesUseCase
        self.createInviteCodeUseCase = createInviteCodeUseCase
        self.revokeInviteCodeUseCase = revokeInviteCodeUseCase
    }

    // MARK: - Display data

    /// "1 người trong ABC". The section header uppercases it.
    var membersTitle: String {
        "\(members.count) \(AppStrings.peopleCountSuffix) \(AppStrings.peopleIn) \(shop.name)"
    }

    /// "abc@abc.com (bạn)" / "Chủ shop"
    var rows: [MemberRow] {
        members.map { member in
            let title = member.email == email ? "\(member.email.value) \(AppStrings.youSuffix)" : member.email.value
            return MemberRow(id: member.id, title: title, subtitle: member.role.title)
        }
    }

    var inviteCards: [InviteCard] {
        invites.map { invite in
            InviteCard(
                id: invite.id,
                code: invite.code.value,
                detail: "\(AppStrings.expiresOn) \(AppFormatters.dayMonth(invite.expiresAt)) · \(AppStrings.usedPrefix) \(invite.useCount) \(AppStrings.timesSuffix)",
                shareMessage: "\(AppStrings.inviteMessagePrefix) \(shop.name) \(AppStrings.inviteMessageOn) \(AppStrings.appName). \(AppStrings.inviteMessageCode) \(invite.code.value)"
            )
        }
    }

    /// "Thu hồi mã CQ4AD2?"
    var revokeConfirmTitle: String {
        guard let pendingRevoke else { return "" }
        return "\(AppStrings.revokeCodePrefix) \(pendingRevoke.code.value)?"
    }

    // MARK: - Actions

    /// Loads members and invites together.
    func load() async {
        async let loadedMembers = loadMembersUseCase.execute(for: shop)
        async let loadedInvites = loadInvitesUseCase.execute(for: shop)
        do {
            members = try await loadedMembers
            invites = try await loadedInvites
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
            let invite = try await createInviteCodeUseCase.execute(for: shop)
            invites.insert(invite, at: 0)
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    /// Asks for confirmation before revoking the code with `id`.
    func requestRevoke(id: InviteCard.ID) {
        pendingRevoke = invites.first { $0.id == id }
    }

    /// Revokes `invite`. The alert passes the invite it was shown for, because dismissing
    /// the alert clears `pendingRevoke` before the button action runs.
    func confirmRevoke(_ invite: ShopInvite) async {
        pendingRevoke = nil
        errorMessage = nil
        revokingCode = invite.code
        defer { revokingCode = nil }

        do {
            try await revokeInviteCodeUseCase.execute(invite, in: shop)
            invites.removeAll { $0.code == invite.code }
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }
}
