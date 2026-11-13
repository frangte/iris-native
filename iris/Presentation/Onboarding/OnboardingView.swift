//
//  OnboardingView.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Lets a freshly signed-in user create a shop or join one with an invite code.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        // GeometryReader + minHeight keeps the content vertically centered while
        // still allowing scrolling when the keyboard shrinks the available height.
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text("\(AppStrings.loginWith) \(viewModel.email.value)")
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                        .padding(.horizontal, DSSpacing.xs)

                    createShopSection
                        .padding(.top, DSSpacing.lg)

                    joinShopSection
                        .padding(.top, DSSpacing.xl)

                    if let errorMessage = viewModel.errorMessage {
                        DSErrorBanner(message: errorMessage)
                            .padding(.top, DSSpacing.md)
                    }

                    DSTextButton(title: AppStrings.logout, action: viewModel.logout)
                        .padding(.top, DSSpacing.xl)

                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.groupedBackground.ignoresSafeArea())
        .animation(.default, value: viewModel.errorMessage)
    }

    // MARK: - Subviews

    private var createShopSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSFormSection(title: AppStrings.openNewShop, footer: AppStrings.youAreOwner) {
                DSFormCard {
                    DSFormRow(
                        label: AppStrings.shopName,
                        placeholder: AppStrings.shopNamePlaceHolder,
                        text: $viewModel.shopName,
                        contentType: .organizationName,
                        autocapitalization: .words
                    )
                    DSFormRow(
                        label: AppStrings.phoneNumber,
                        placeholder: AppStrings.optional,
                        text: $viewModel.phone,
                        keyboardType: .phonePad,
                        contentType: .telephoneNumber
                    )
                    DSFormRow(
                        label: AppStrings.address,
                        placeholder: AppStrings.addressPlaceHolder,
                        text: $viewModel.address,
                        contentType: .fullStreetAddress
                    )
                }
            }

            DSPrimaryButton(
                title: AppStrings.createShop,
                isEnabled: viewModel.canCreateShop,
                isLoading: viewModel.activeAction == .createShop
            ) {
                Task { await viewModel.createShop() }
            }
            .padding(.top, DSSpacing.lg)
        }
    }

    private var joinShopSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSFormSection(title: AppStrings.joinExistingShop, footer: AppStrings.getNewCodeGuide) {
                DSFormCard {
                    DSFormRow(
                        label: AppStrings.invitationCode,
                        placeholder: AppStrings.invitationCodePlaceholder,
                        text: $viewModel.inviteCode,
                        keyboardType: .asciiCapable,
                        autocapitalization: .characters,
                        disablesAutocorrection: true
                    )
                }
            }

            DSTonalButton(
                title: AppStrings.joinShop,
                isEnabled: viewModel.canJoinShop,
                isLoading: viewModel.activeAction == .joinShop
            ) {
                Task { await viewModel.joinShop() }
            }
            .padding(.top, DSSpacing.lg)
        }
    }
}

#Preview {
    let repository = InMemoryShopRepository(simulatedDelay: .zero)
    OnboardingView(
        viewModel: OnboardingViewModel(
            email: Email("abc@abc.com")!,
            createShopUseCase: CreateShopUseCase(repository: repository),
            joinShopUseCase: JoinShopUseCase(repository: repository),
            onShopReady: { _ in },
            onLogout: {}
        )
    )
}
