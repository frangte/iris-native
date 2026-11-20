//
//  ShopInfoView.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// Edit screen for the shop name, phone and pickup address. Pushed from the Shop tab.
struct ShopInfoView: View {
    @State private var viewModel: ShopInfoViewModel

    init(viewModel: ShopInfoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                DSFormSection(title: AppStrings.shopInfo, footer: AppStrings.shopInfoFooter) {
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
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
            .padding(.bottom, DSSpacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.groupedBackground.ignoresSafeArea())
        .navigationTitle(AppStrings.shopInfo)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button(AppStrings.save) {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
        .animation(.default, value: viewModel.errorMessage)
    }
}

#Preview {
    NavigationStack {
        ShopInfoView(
            viewModel: ShopInfoViewModel(
                shop: Shop(id: "1", name: "Tiệm hoa Mộc", phone: "0909 123 456", address: nil),
                updateShopUseCase: UpdateShopUseCase(repository: InMemoryShopRepository(simulatedDelay: .zero)),
                onSaved: { _ in }
            )
        )
    }
}
