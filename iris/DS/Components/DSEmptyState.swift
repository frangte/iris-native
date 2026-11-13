//
//  DSEmptyState.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import SwiftUI

/// Centered title, explanation and a compact call-to-action shown when a list has nothing to display.
struct DSEmptyState: View {
    let title: String
    let message: String
    let actionTitle: String
    let actionSystemImage: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Text(title)
                .font(DSFont.headline)
                .foregroundStyle(Color.label)
            Text(message)
                .font(DSFont.subhead)
                .foregroundStyle(Color.secondaryLabel)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Label(actionTitle, systemImage: actionSystemImage)
                    .font(DSFont.headline)
                    .foregroundStyle(Color.onTint)
                    .padding(.horizontal, DSSpacing.xl)
                    .frame(height: DSSpacing.buttonHeight)
                    .background(Color.tint, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
            }
            .buttonStyle(.plain)
            .padding(.top, DSSpacing.lg)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DSEmptyState(
        title: AppStrings.noOrder,
        message: AppStrings.todayOrderDesc,
        actionTitle: AppStrings.createFirstOrder,
        actionSystemImage: "plus"
    ) {}
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
