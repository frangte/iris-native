//
//  DSNavigationRow.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// List line that leads somewhere: optional tinted icon, title with an optional subtitle,
/// an optional trailing value, and a disclosure chevron. Intended to be placed inside `DSFormCard`.
/// Content only; wrap it in a `NavigationLink` or `Button` to make it tappable.
struct DSNavigationRow: View {
    var systemImage: String? = nil
    let title: String
    var subtitle: String? = nil
    var value: String? = nil

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.tint)
                    .frame(width: DSSpacing.iconSize)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.body)
                    .foregroundStyle(Color.label)
                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                }
            }

            Spacer(minLength: 0)

            if let value {
                Text(value)
                    .font(DSFont.body)
                    .foregroundStyle(Color.secondaryLabel)
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.tertiaryLabel)
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, subtitle == nil ? 0 : DSSpacing.sm)
        .frame(minHeight: DSSpacing.rowHeight)
        .contentShape(Rectangle())
    }
}

#Preview {
    DSFormCard {
        DSNavigationRow(title: AppStrings.shopInfo, subtitle: AppStrings.shopInfoSubtitle)
        DSNavigationRow(title: AppStrings.bankTransferVietQR, value: AppStrings.notSetUp)
        DSNavigationRow(systemImage: "person.2.fill", title: AppStrings.members, value: "1 người")
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
