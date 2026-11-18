//
//  OrderDetailView.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Order detail: status header and primary action, payment, delivery hand-off,
/// customer, products, notes, history and the cancel/delete zone. Pushed inside a navigation stack.
struct OrderDetailView: View {
    @State private var viewModel: OrderDetailViewModel
    @Environment(\.openURL) private var openURL

    init(viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                header

                if let errorMessage = viewModel.errorMessage {
                    DSErrorBanner(message: errorMessage)
                }

                statusCard
                paymentSection

                if viewModel.showsDelivery {
                    deliverySection
                }

                customerSection
                productsSection

                if viewModel.hasNotes {
                    notesSection
                }

                historySection
                dangerZone
            }
            .padding(.horizontal, DSSpacing.screenPadding)
            .padding(.top, DSSpacing.md)
            .padding(.bottom, DSSpacing.xl)
        }
        .background(Color.groupedBackground.ignoresSafeArea())
        .navigationTitle(viewModel.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppStrings.edit, action: viewModel.edit)
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .confirmationDialog(AppStrings.cancelOrderConfirm, isPresented: $viewModel.isConfirmingCancel, titleVisibility: .visible) {
            Button(AppStrings.cancelOrder, role: .destructive) {
                Task { await viewModel.confirmCancel() }
            }
            Button(AppStrings.keep, role: .cancel) {}
        }
        .confirmationDialog(AppStrings.deleteOrderConfirm, isPresented: $viewModel.isConfirmingDelete, titleVisibility: .visible) {
            Button(AppStrings.deleteForever, role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
            Button(AppStrings.keep, role: .cancel) {}
        }
        .overlay(alignment: .bottom) { toast }
        .animation(.default, value: viewModel.order)
        .animation(.default, value: viewModel.errorMessage)
        .animation(.default, value: viewModel.toastMessage)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.sm) {
                    DSStatusPill(title: viewModel.statusTitle, style: viewModel.order.status.pillStyle)
                    if viewModel.isLate {
                        DSStatusPill(title: AppStrings.lateTag, style: .danger)
                    }
                }

                Text(viewModel.customerName)
                    .font(DSFont.title1)
                    .foregroundStyle(Color.label)

                Text(viewModel.scheduleLine)
                    .font(DSFont.callout)
                    .foregroundStyle(viewModel.isLate ? Color.danger : Color.secondaryLabel)
            }
            .padding(.horizontal, DSSpacing.xs)

            if let title = viewModel.primaryActionTitle {
                DSPrimaryButton(title: title, isEnabled: true, isLoading: viewModel.isUpdating) {
                    Task { await viewModel.advanceStatus() }
                }
            }
        }
    }

    private var statusCard: some View {
        DSFormCard {
            Menu {
                ForEach(viewModel.statusOptions, id: \.self) { status in
                    Button {
                        Task { await viewModel.changeStatus(to: status) }
                    } label: {
                        if status == viewModel.order.status {
                            Label(status.title, systemImage: "checkmark")
                        } else {
                            Text(status.title)
                        }
                    }
                }
            } label: {
                DSRow(label: AppStrings.changeStatus) {
                    HStack(spacing: DSSpacing.xs) {
                        Text(viewModel.statusTitle)
                            .font(DSFont.body)
                            .foregroundStyle(Color.secondaryLabel)
                        chevron
                    }
                }
                .contentShape(Rectangle())
            }
            .disabled(viewModel.isUpdating)
        }
    }

    // MARK: - Sections

    private var paymentSection: some View {
        DSFormSection(title: AppStrings.payment, footer: nil) {
            OrderPaymentCard(viewModel: viewModel)
        }
    }

    private var deliverySection: some View {
        DSFormSection(title: AppStrings.deliverTo, footer: AppStrings.deliveryAppsHint) {
            OrderDeliveryCard(viewModel: viewModel)
        }
    }

    private var customerSection: some View {
        DSFormSection(title: AppStrings.customerOrder, footer: nil) {
            DSFormCard {
                // TODO: push the customer screen once it exists.
                DSInfoRow(title: viewModel.customerName, subtitle: viewModel.customerLine) {
                    chevron
                }

                if let url = viewModel.zaloURL {
                    DSActionRow(title: AppStrings.messageZalo, systemImage: "message.fill", style: .neutral) {
                        openURL(url)
                    }
                }
            }
        }
    }

    private var productsSection: some View {
        DSFormSection(title: AppStrings.product, footer: nil) {
            DSFormCard {
                ForEach(viewModel.productLines) { line in
                    DSRow(label: line.title) {
                        moneyText(line.amount, font: DSFont.body)
                    }
                }

                if let shipping = viewModel.shippingFeeText {
                    DSRow(label: AppStrings.shippingFee, labelColor: .secondaryLabel) {
                        moneyText(shipping, font: DSFont.body)
                    }
                }

                if let discount = viewModel.discountText {
                    DSRow(label: AppStrings.discount, labelColor: .secondaryLabel) {
                        moneyText(discount, font: DSFont.body)
                    }
                }

                DSRow(label: AppStrings.total, labelFont: DSFont.headline) {
                    moneyText(viewModel.totalText, font: DSFont.headline)
                }
            }
        }
    }

    private var notesSection: some View {
        DSFormSection(title: AppStrings.cardAndNotes, footer: nil) {
            DSFormCard {
                if let cardMessage = viewModel.cardMessage {
                    DSInfoRow(systemImage: "greetingcard", title: AppStrings.cardMessage, subtitle: cardMessage)
                }
                if let note = viewModel.note {
                    DSInfoRow(systemImage: "note.text", title: AppStrings.note, subtitle: note)
                }
            }
        }
    }

    private var historySection: some View {
        DSFormSection(title: AppStrings.history, footer: nil) {
            DSFormCard {
                ForEach(viewModel.historyEntries) { entry in
                    DSInfoRow(title: entry.title, subtitle: entry.detail)
                }
            }
        }
    }

    private var dangerZone: some View {
        VStack(spacing: DSSpacing.md) {
            if viewModel.canCancel {
                DSTonalButton(
                    title: AppStrings.cancelOrder,
                    isEnabled: true,
                    isLoading: false,
                    style: .destructive,
                    action: viewModel.requestCancel
                )
            }
            DSTextButton(title: AppStrings.deleteForever, style: .destructive, action: viewModel.requestDelete)
        }
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Helpers

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.tertiaryLabel)
    }

    private func moneyText(_ value: String, font: Font) -> some View {
        Text(value)
            .font(font.money)
            .foregroundStyle(Color.label)
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

// MARK: - Preview

#if DEBUG
private enum OrderDetailPreviewData {
    static let shop = Shop(id: "1", name: "Tiệm hoa Mộc", phone: nil, address: nil)
    static let actor = Email("abc@abc.com")

    /// A late, unpaid delivery order so every section of the screen is visible.
    static var order: Order? {
        guard let actor else { return nil }
        var input = OrderInput(deliveryDate: Calendar.current.startOfDay(for: Date()))
        input.customerName = "Chị Thảo"
        input.customerPhone = "0909 123 456"
        input.items[0].name = "Bó hồng đỏ 20 cành"
        input.items[0].unitPrice = 450_000
        input.hasTimeWindow = true
        input.startTime = TimeOfDay(hour: 8)
        input.endTime = TimeOfDay(hour: 10)
        input.address = "12 Nguyễn Huệ, Quận 1"
        input.cardMessage = "Chúc mừng sinh nhật mẹ"
        input.shippingFee = 30_000
        input.deposit = 200_000
        guard let draft = try? OrderDraft(input) else { return nil }
        return Order(
            id: "order-1",
            number: 1,
            shopId: shop.id,
            createdAt: Date(),
            details: draft,
            history: [OrderEvent(kind: .created, actor: actor, date: Date())]
        )
    }
}

#Preview {
    if let order = OrderDetailPreviewData.order, let actor = OrderDetailPreviewData.actor {
        let repository = InMemoryOrderRepository(simulatedDelay: .zero, orders: [order])
        NavigationStack {
            OrderDetailView(
                viewModel: OrderDetailViewModel(
                    order: order,
                    shop: OrderDetailPreviewData.shop,
                    actor: actor,
                    loadOrder: LoadOrderUseCase(repository: repository),
                    changeStatusUseCase: ChangeOrderStatusUseCase(repository: repository),
                    deleteOrderUseCase: DeleteOrderUseCase(repository: repository),
                    onChanged: {},
                    onDeleted: {}
                )
            )
        }
        .tint(Color.tint)
    }
}
#endif
