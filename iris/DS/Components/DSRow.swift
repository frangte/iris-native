//
//  DSRow.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Generic grouped-list line: label on the left, any control or value on the right.
/// Intended to be placed inside `DSFormCard`.
struct DSRow<Trailing: View>: View {
    let label: String
    var labelFont: Font = DSFont.body
    var labelColor: Color = .label
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Text(label)
                .font(labelFont)
                .foregroundStyle(labelColor)

            Spacer(minLength: 0)

            trailing
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .frame(minHeight: DSSpacing.rowHeight)
    }
}

#Preview {
    DSFormCard {
        DSRow(label: AppStrings.orderTotal, labelColor: .secondaryLabel) {
            Text(AppFormatters.money(1_200_000))
                .font(DSFont.headline.money)
        }
        DSRow(label: AppStrings.remainingAmount, labelFont: DSFont.headline) {
            Text(AppFormatters.money(700_000))
                .font(DSFont.title2.money)
        }
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
