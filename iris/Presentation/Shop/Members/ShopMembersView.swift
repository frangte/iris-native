//
//  ShopMembersView.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// Member list and invite codes. Pushed from the Shop tab.
struct ShopMembersView: View {
    @State private var viewModel: ShopMembersViewModel

    init(viewModel: ShopMembersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                membersSection

                if let errorMessage = viewModel.errorMessage {
                    DSErrorBanner(message: errorMessage)
                }

                inviteSection
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
            .padding(.bottom, DSSpacing.xl)
        }
        .background(Color.groupedBackground.ignoresSafeArea())
        .navigationTitle(AppStrings.members)
        .toolbarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .background { revokeAlertHost }
        .animation(.default, value: viewModel.rows)
        .animation(.default, value: viewModel.inviteCards)
        .animation(.default, value: viewModel.errorMessage)
    }

    // MARK: - Sections

    private var membersSection: some View {
        DSFormSection(title: viewModel.membersTitle, footer: AppStrings.onlyOwnerRemovesMembers) {
            DSFormCard {
                ForEach(viewModel.rows) { row in
                    DSInfoRow(systemImage: "person.crop.circle", iconColor: .tint, title: row.title, subtitle: row.subtitle)
                }
            }
        }
    }

    private var inviteSection: some View {
        DSFormSection(title: AppStrings.inviteManager, footer: AppStrings.inviteCodeHint) {
            DSFormCard {
                ForEach(viewModel.inviteCards) { invite in
                    InviteCodeCard(
                        invite: invite,
                        isRevoking: viewModel.revokingCode?.value == invite.code
                    ) {
                        viewModel.requestRevoke(id: invite.id)
                    }
                }

                DSActionRow(title: AppStrings.createInviteCode, systemImage: "ticket") {
                    Task { await viewModel.createInviteCode() }
                }
                .disabled(viewModel.isCreatingCode)
                .overlay(alignment: .trailing) {
                    if viewModel.isCreatingCode {
                        ProgressView()
                            .padding(.trailing, DSSpacing.controlInset)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    /// Hosts the revoke confirmation with a neutral tint so "Huỷ" is black instead of the
    /// brand pink the navigation stack sets. Scoped to this hidden view so the screen keeps its tint.
    private var revokeAlertHost: some View {
        Color.clear
            .alert(viewModel.revokeConfirmTitle, isPresented: isConfirmingRevoke, presenting: viewModel.pendingRevoke) { invite in
                Button(AppStrings.cancel, role: .cancel) {}
                Button(AppStrings.revoke, role: .destructive) {
                    Task { await viewModel.confirmRevoke(invite) }
                }
            }
            .tint(Color.label)
    }

    /// Shows the alert while an invite waits for confirmation; dismissing clears it.
    private var isConfirmingRevoke: Binding<Bool> {
        Binding(
            get: { viewModel.pendingRevoke != nil },
            set: { if !$0 { viewModel.pendingRevoke = nil } }
        )
    }
}

#Preview {
    let repository = InMemoryShopRepository(simulatedDelay: .zero)
    if let email = Email("abc@abc.com") {
        NavigationStack {
            ShopMembersView(
                viewModel: ShopMembersViewModel(
                    shop: Shop(id: "1", name: "ABC", phone: nil, address: nil),
                    email: email,
                    members: [ShopMember(email: email, role: .owner)],
                    loadMembersUseCase: LoadShopMembersUseCase(repository: repository),
                    loadInvitesUseCase: LoadShopInvitesUseCase(repository: repository),
                    createInviteCodeUseCase: CreateInviteCodeUseCase(repository: repository),
                    revokeInviteCodeUseCase: RevokeInviteCodeUseCase(repository: repository)
                )
            )
        }
    }
}
