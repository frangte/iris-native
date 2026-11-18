//
//  OrderDeliveryCard.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Who receives the flowers and where, shortcuts into shipping apps, and a copy action.
/// Opening an app copies the delivery info first so it can be pasted straight in.
struct OrderDeliveryCard: View {
    let viewModel: OrderDetailViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        DSFormCard {
            DSInfoRow(systemImage: "person.crop.circle", title: viewModel.recipientName, subtitle: viewModel.recipientPhone) {
                if let url = viewModel.callURL {
                    callButton(url)
                }
            }

            DSInfoRow(systemImage: "map", title: viewModel.addressTitle, subtitle: viewModel.addressSubtitle)

            appButtons

            DSActionRow(
                title: AppStrings.copyDeliveryInfo,
                systemImage: "doc.on.doc",
                style: .neutral,
                action: viewModel.copyDeliveryInfo
            )
        }
    }

    // MARK: - Subviews

    private func callButton(_ url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            Text(AppStrings.call)
                .font(DSFont.subhead.weight(.semibold))
                .foregroundStyle(Color.tint)
                .padding(.horizontal, DSSpacing.lg)
                .frame(height: DSSpacing.smallButtonHeight)
                .background(Color.tintSoft, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var appButtons: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(viewModel.deliveryAppRows, id: \.self) { row in
                HStack(spacing: DSSpacing.sm) {
                    ForEach(row) { app in
                        appButton(app)
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, DSSpacing.md)
    }

    private func appButton(_ app: DeliveryApp) -> some View {
        Button {
            viewModel.copyDeliveryInfo()
            open(app)
        } label: {
            Text(app.title)
                .font(DSFont.subhead.weight(.semibold))
                .foregroundStyle(Color.label)
                .frame(maxWidth: .infinity)
                .frame(height: DSSpacing.rowHeight)
                .background(Color.fill, in: RoundedRectangle(cornerRadius: DSSpacing.controlRadius))
        }
        .buttonStyle(.plain)
    }

    /// Opens the app, or its App Store page when it is not installed.
    private func open(_ app: DeliveryApp) {
        guard let appURL = app.appURL else { return }
        openURL(appURL) { accepted in
            if !accepted, let storeURL = app.storeURL {
                openURL(storeURL)
            }
        }
    }
}
