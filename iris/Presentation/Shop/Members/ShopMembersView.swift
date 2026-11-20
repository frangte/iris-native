//
//  ShopMembersView.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// Member list and invite code. Pushed from the Shop tab.
struct ShopMembersView: View {
    @State private var viewModel: ShopMembersViewModel

    init(viewModel: ShopMembersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSFormSection(title: AppStrings.members, footer: AppStrings.membersFooter) {
                    DSFormCard {
                        ForEach(viewModel.rows) { row in
                            DSInfoRow(systemImage: "person.crop.circle", title: row.title, subtitle: row.subtitle)
                        }
                    }
                }

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
        .overlay(alignment: .bottom) { toast }
        .animation(.default, value: viewModel.rows)
        .animation(.default, value: viewModel.inviteCode)
        .animation(.default, value: viewModel.errorMessage)
        .animation(.default, value: viewModel.toastMessage)
    }

    // MARK: - Sections

    private var inviteSection: some View {
        DSFormSection(title: AppStrings.inviteMore, footer: AppStrings.inviteCodeHint) {
            DSFormCard {
                if let inviteCode = viewModel.inviteCode {
                    DSInfoRow(systemImage: "key", title: inviteCode.value, subtitle: AppStrings.invitationCode) {
                        Button(AppStrings.copyInviteCode, action: viewModel.copyInviteCode)
                            .font(DSFont.subhead.weight(.semibold))
                            .foregroundStyle(Color.tint)
                    }
                    if let inviteMessage = viewModel.inviteMessage {
                        ShareLink(item: inviteMessage) {
                            DSActionLabel(title: AppStrings.shareInviteCode, systemImage: "square.and.arrow.up", style: .neutral)
                        }
                        .buttonStyle(.plain)
                    }
                    inviteCodeButton(title: AppStrings.createNewInviteCode, systemImage: "arrow.clockwise")
                } else {
                    inviteCodeButton(title: AppStrings.createInviteCode, systemImage: "person.badge.plus")
                }
            }
        }
    }

    // MARK: - Subviews

    private func inviteCodeButton(title: String, systemImage: String) -> some View {
        DSActionRow(title: title, systemImage: systemImage) {
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

    @ViewBuilder
    private var toast: some View {
        if let message = viewModel.toastMessage {
            Text(message)
                .font(DSFont.subhead)
                .foregroundStyle(Color.cell)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.md)
                .background(Color.label.opacity(0.9), in: Capsule())
                .padding(.bottom, DSSpacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    let repository = InMemoryShopRepository(simulatedDelay: .zero)
    if let email = Email("abc@abc.com") {
        NavigationStack {
            ShopMembersView(
                viewModel: ShopMembersViewModel(
                    shop: Shop(id: "1", name: "Tiệm hoa Mộc", phone: nil, address: nil),
                    email: email,
                    members: [ShopMember(email: email, role: .owner)],
                    loadMembersUseCase: LoadShopMembersUseCase(repository: repository),
                    createInviteCodeUseCase: CreateInviteCodeUseCase(repository: repository)
                )
            )
        }
    }
}
