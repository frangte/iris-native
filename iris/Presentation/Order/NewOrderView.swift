//
//  NewOrderView.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Modal form to create an order. Presented as a sheet from the Today tab.
struct NewOrderView: View {
    @State private var viewModel: NewOrderViewModel
    /// True while any field in the form has the keyboard. Cleared by the "Done" keyboard button.
    @FocusState private var isEditing: Bool

    init(viewModel: NewOrderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    customerSection
                    productsSection
                    deliverySection

                    if viewModel.showsDeliveryAddress {
                        recipientSection
                    }

                    notesSection
                    paymentSection

                    if let errorMessage = viewModel.errorMessage {
                        DSErrorBanner(message: errorMessage)
                    }

                    footer
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
                .focused($isEditing)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.groupedBackground.ignoresSafeArea())
            .navigationTitle(AppStrings.newOrder)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel, action: viewModel.cancel)
                        .disabled(viewModel.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.save) {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AppStrings.done) { isEditing = false }
                }
            }
            .interactiveDismissDisabled(viewModel.isSaving)
            .animation(.default, value: viewModel.errorMessage)
            .animation(.default, value: viewModel.showsDeliveryAddress)
            .animation(.default, value: viewModel.input.hasSeparateRecipient)
            .animation(.default, value: viewModel.input.items.count)
        }
        .tint(Color.tint)
    }

    // MARK: - Sections

    private var customerSection: some View {
        DSFormSection(title: AppStrings.customerOrder, footer: nil) {
            DSFormCard {
                DSFormRow(
                    label: AppStrings.name,
                    placeholder: AppStrings.customerNamePlaceholder,
                    text: $viewModel.input.customerName,
                    contentType: .name,
                    autocapitalization: .words
                )
                DSFormRow(
                    label: AppStrings.phoneNumber,
                    placeholder: AppStrings.customerPhonePlaceholder,
                    text: $viewModel.input.customerPhone,
                    keyboardType: .phonePad,
                    contentType: .telephoneNumber
                )
            }

            DSFlowLayout {
                ForEach(viewModel.sourceOptions, id: \.self) { source in
                    DSChip(title: source.title, isSelected: viewModel.input.source == source) {
                        viewModel.input.source = source
                    }
                }
            }
            .padding(.top, DSSpacing.xs)
        }
    }

    private var productsSection: some View {
        DSFormSection(title: AppStrings.product, footer: nil) {
            OrderItemsCard(
                items: $viewModel.input.items,
                canRemove: viewModel.canRemoveItems,
                onAdd: viewModel.addItem,
                onRemove: { viewModel.removeItem(id: $0) }
            )
        }
    }

    private var deliverySection: some View {
        DSFormSection(title: AppStrings.delivery, footer: nil) {
            DSSegmentedPicker(options: viewModel.deliveryMethodOptions, selection: $viewModel.input.deliveryMethod) {
                $0.title
            }

            DeliveryScheduleCard(viewModel: viewModel)
                .padding(.top, DSSpacing.xs)
        }
    }

    private var recipientSection: some View {
        DSFormSection(title: AppStrings.deliverTo, footer: nil) {
            DSFormCard {
                DSFormRow(
                    label: AppStrings.address,
                    placeholder: AppStrings.deliveryAddressPlaceholder,
                    text: $viewModel.input.address,
                    contentType: .fullStreetAddress
                )

                if viewModel.input.hasSeparateRecipient {
                    DSFormRow(
                        label: AppStrings.recipient,
                        placeholder: AppStrings.recipientNamePlaceholder,
                        text: $viewModel.input.recipientName,
                        contentType: .name,
                        autocapitalization: .words
                    )
                    DSFormRow(
                        label: AppStrings.phoneNumber,
                        placeholder: AppStrings.customerPhonePlaceholder,
                        text: $viewModel.input.recipientPhone,
                        keyboardType: .phonePad,
                        contentType: .telephoneNumber
                    )
                }

                DSRow(label: viewModel.recipientLine) {
                    Button(viewModel.recipientToggleTitle, action: viewModel.toggleSeparateRecipient)
                        .font(DSFont.body)
                        .foregroundStyle(Color.tint)
                }
            }
        }
    }

    private var notesSection: some View {
        DSFormSection(title: AppStrings.cardAndNotes, footer: nil) {
            DSFormCard {
                DSFormRow(
                    label: AppStrings.cardMessage,
                    placeholder: AppStrings.cardMessagePlaceholder,
                    text: $viewModel.input.cardMessage
                )
                DSFormRow(
                    label: AppStrings.note,
                    placeholder: AppStrings.notePlaceholder,
                    text: $viewModel.input.note,
                    axis: .vertical
                )
            }
        }
    }

    private var paymentSection: some View {
        DSFormSection(title: AppStrings.payment, footer: nil) {
            DSFormCard {
                MoneyFieldRow(label: AppStrings.shippingFee, amount: $viewModel.input.shippingFee)
                MoneyFieldRow(label: AppStrings.discount, amount: $viewModel.input.discount)
                MoneyFieldRow(label: AppStrings.deposit, amount: $viewModel.input.deposit)

                // Grouped in one subview so the card draws no divider between the two totals.
                VStack(spacing: 0) {
                    DSRow(label: AppStrings.orderTotal, labelColor: .secondaryLabel) {
                        Text(viewModel.totalText)
                            .font(DSFont.headline.money)
                            .foregroundStyle(Color.label)
                    }
                    DSRow(label: AppStrings.remainingAmount, labelFont: DSFont.headline) {
                        Text(viewModel.remainingText)
                            .font(DSFont.title2.money)
                            .foregroundStyle(Color.label)
                    }
                }
                .padding(.vertical, DSSpacing.xs)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: DSSpacing.md) {
            if let hint = viewModel.validationHint {
                Text(hint)
                    .font(DSFont.footnote)
                    .foregroundStyle(Color.secondaryLabel)
                    .frame(maxWidth: .infinity)
            }

            DSPrimaryButton(
                title: viewModel.saveButtonTitle,
                isEnabled: viewModel.canSave,
                isLoading: viewModel.isSaving
            ) {
                Task { await viewModel.save() }
            }
        }
        .animation(.default, value: viewModel.validationHint)
    }
}

#Preview {
    if let actor = Email("abc@abc.com") {
        NewOrderView(
            viewModel: NewOrderViewModel(
                shop: Shop(id: "1", name: "ABC", phone: nil, address: nil),
                actor: actor,
                createOrderUseCase: CreateOrderUseCase(repository: InMemoryOrderRepository(simulatedDelay: .zero)),
                onSaved: { _ in },
                onCancel: {}
            )
        )
    }
}
