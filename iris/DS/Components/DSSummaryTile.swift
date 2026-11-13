//
//  DSSummaryTile.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import SwiftUI

/// Small card with a caption and a large tabular figure. Used in a row of equal-width tiles.
struct DSSummaryTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(label)
                .font(DSFont.footnote)
                .foregroundStyle(Color.secondaryLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(DSFont.title2.money)
                .foregroundStyle(Color.label)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.lg)
        .background(Color.cell, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
    }
}

#Preview {
    HStack(spacing: DSSpacing.md) {
        DSSummaryTile(label: AppStrings.ordersToday, value: "0")
        DSSummaryTile(label: AppStrings.late, value: "0")
        DSSummaryTile(label: AppStrings.remainingMoney, value: AppFormatters.money(0))
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
