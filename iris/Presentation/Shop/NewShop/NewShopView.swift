//
//  NewShopView.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// Sheet for opening another shop from the Shop tab.
struct NewShopView: View {
    @State private var viewModel: NewShopViewModel

    init(viewModel: NewShopViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    DSFormSection(title: AppStrings.shopInfo, footer: AppStrings.youAreOwner) {
                        DSFormCard {
                            DSFormRow(
                                label: AppStrings.shopName,
                                placeholder: AppStrings.shopNamePlaceHolder,
                                text: $viewModel.name,
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

                    if let errorMessage = viewModel.errorMessage {
                        DSErrorBanner(message: errorMessage)
                    }

                    DSPrimaryButton(
                        title: AppStrings.createShop,
                        isEnabled: viewModel.canCreate,
                        isLoading: viewModel.isCreating
                    ) {
                        Task { await viewModel.create() }
                    }
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.groupedBackground.ignoresSafeArea())
            .navigationTitle(AppStrings.openAnotherShop)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(AppStrings.cancel, action: viewModel.cancel)
                }
            }
            .animation(.default, value: viewModel.errorMessage)
        }
        .tint(Color.tint)
    }
}

#Preview {
    if let email = Email("abc@abc.com") {
        NewShopView(
            viewModel: NewShopViewModel(
                email: email,
                createShopUseCase: CreateShopUseCase(repository: InMemoryShopRepository(simulatedDelay: .zero)),
                onCreated: { _ in },
                onCancel: {}
            )
        )
    }
}
