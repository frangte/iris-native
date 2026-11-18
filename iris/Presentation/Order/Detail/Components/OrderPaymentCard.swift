//
//  OrderPaymentCard.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Money still to collect as the headline, the total and collected breakdown, and a share action
/// that sends a plain-text receipt to the customer.
struct OrderPaymentCard: View {
    let viewModel: OrderDetailViewModel

    var body: some View {
        DSFormCard {
            // One subview so the card draws no divider between the headline amount and the breakdown.
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(viewModel.paymentCaption)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                    Text(viewModel.remainingText)
                        .font(DSFont.largeTitle.money)
                        .foregroundStyle(viewModel.isFullyPaid ? Color.success : Color.label)
                }

                VStack(spacing: DSSpacing.xs) {
                    moneyLine(AppStrings.orderTotal, viewModel.totalText)
                    moneyLine(AppStrings.collected, viewModel.collectedText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.controlInset)
            .padding(.vertical, DSSpacing.lg)

            ShareLink(item: viewModel.invoiceText) {
                DSActionLabel(
                    title: AppStrings.sendInvoice,
                    subtitle: AppStrings.sendInvoiceHint,
                    systemImage: "square.and.arrow.up",
                    style: .neutral
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func moneyLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(DSFont.subhead)
                .foregroundStyle(Color.secondaryLabel)
            Spacer(minLength: 0)
            Text(value)
                .font(DSFont.subhead.money)
                .foregroundStyle(Color.label)
        }
    }
}
