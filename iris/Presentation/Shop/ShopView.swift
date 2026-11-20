//
//  ShopView.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// Shop tab: shop header and settings links, members, other shops, account and sign-out.
struct ShopView: View {
    @State private var viewModel: ShopViewModel

    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    shopCard
                    membersSection
                    otherShopsSection

                    if let errorMessage = viewModel.errorMessage {
                        DSErrorBanner(message: errorMessage)
                    }

                    accountSection
                    footer
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.groupedBackground.ignoresSafeArea())
            .navigationTitle(AppStrings.shop)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .animation(.default, value: viewModel.errorMessage)
            .animation(.default, value: viewModel.canJoinShop)
            .confirmationDialog(AppStrings.logoutConfirm, isPresented: $viewModel.isConfirmingLogout, titleVisibility: .visible) {
                Button(AppStrings.logout, role: .destructive, action: viewModel.logout)
            }
            .sheet(isPresented: $viewModel.isCreatingShop) {
                NewShopView(viewModel: viewModel.makeNewShopViewModel())
            }
            .navigationDestination(for: ShopRoute.self) { route in
                switch route {
                case .info:
                    ShopInfoView(viewModel: viewModel.makeShopInfoViewModel())
                case .payment:
                    ShopComingSoonView(title: AppStrings.bankTransferVietQR)
                case .members:
                    ShopMembersView(viewModel: viewModel.makeMembersViewModel())
                }
            }
        }
        .tint(Color.tint)
    }

    // MARK: - Sections

    private var shopCard: some View {
        DSFormCard {
            shopHeader

            NavigationLink(value: ShopRoute.info) {
                DSNavigationRow(title: AppStrings.shopInfo, subtitle: AppStrings.shopInfoSubtitle)
            }
            .buttonStyle(.plain)

            NavigationLink(value: ShopRoute.payment) {
                DSNavigationRow(title: AppStrings.bankTransferVietQR, value: AppStrings.notSetUp)
            }
            .buttonStyle(.plain)
        }
    }

    private var membersSection: some View {
        DSFormSection(title: AppStrings.manageTogether, footer: AppStrings.membersFooter) {
            DSFormCard {
                NavigationLink(value: ShopRoute.members) {
                    DSNavigationRow(
                        systemImage: "person.2.fill",
                        title: AppStrings.members,
                        value: viewModel.memberCountText
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var otherShopsSection: some View {
        DSFormSection(title: AppStrings.otherShops, footer: nil) {
            DSFormCard {
                DSActionRow(title: AppStrings.openAnotherShop, systemImage: "plus", action: viewModel.openNewShop)

                HStack(spacing: 0) {
                    DSFormRow(
                        label: AppStrings.invitationCode,
                        placeholder: AppStrings.joinOtherShopPlaceholder,
                        text: $viewModel.inviteCode,
                        keyboardType: .asciiCapable,
                        autocapitalization: .characters,
                        disablesAutocorrection: true
                    )

                    // The join button appears once the code has the right shape.
                    if viewModel.canJoinShop {
                        joinButton
                            .padding(.trailing, DSSpacing.controlInset)
                            .transition(.opacity)
                    }
                }
            }
        }
    }

    private var accountSection: some View {
        DSFormSection(title: AppStrings.account, footer: viewModel.email.value) {
            DSFormCard {
                DSFormRow(
                    label: AppStrings.yourName,
                    placeholder: AppStrings.yourNamePlaceholder,
                    text: $viewModel.displayName,
                    contentType: .name,
                    autocapitalization: .words
                )
            }
        }
    }

    private var footer: some View {
        VStack(spacing: DSSpacing.lg) {
            DSTonalButton(
                title: AppStrings.logout,
                isEnabled: true,
                isLoading: false,
                style: .destructive,
                systemImage: "rectangle.portrait.and.arrow.right",
                action: viewModel.requestLogout
            )

            Text(viewModel.buildLine)
                .font(DSFont.footnote)
                .foregroundStyle(Color.tertiaryLabel)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Subviews

    private var shopHeader: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: "storefront")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.tint)
                .frame(width: DSSpacing.iconSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.shop.name)
                    .font(DSFont.title3)
                    .foregroundStyle(Color.label)
                if let roleTitle = viewModel.roleTitle {
                    Text(roleTitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, DSSpacing.md)
        .frame(minHeight: DSSpacing.rowHeight)
    }

    private var joinButton: some View {
        Button {
            Task { await viewModel.joinShop() }
        } label: {
            ZStack {
                Text(AppStrings.join)
                    .font(DSFont.subhead.weight(.semibold))
                    .opacity(viewModel.isJoining ? 0 : 1)
                if viewModel.isJoining {
                    ProgressView()
                }
            }
            .foregroundStyle(Color.tint)
            .padding(.horizontal, DSSpacing.md)
            .frame(height: DSSpacing.smallButtonHeight)
            .background(Color.tint.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isJoining)
    }
}

/// Placeholder for shop settings that are not built yet.
private struct ShopComingSoonView: View {
    let title: String

    var body: some View {
        Text(AppStrings.comingSoon)
            .font(DSFont.subhead)
            .foregroundStyle(Color.secondaryLabel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.groupedBackground.ignoresSafeArea())
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = AppContainer(
        authRepository: InMemoryAuthRepository(),
        shopRepository: InMemoryShopRepository(simulatedDelay: .zero),
        orderRepository: InMemoryOrderRepository(simulatedDelay: .zero)
    )
    if let email = Email("abc@abc.com") {
        ShopView(
            viewModel: container.makeShopViewModel(
                for: Shop(id: "1", name: "ABC", phone: nil, address: nil),
                email: email
            )
        )
    }
}
