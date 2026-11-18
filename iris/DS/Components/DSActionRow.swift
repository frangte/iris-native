//
//  DSActionRow.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Tappable list line with an icon, e.g. "Add product" or "Delete product".
/// Intended to be placed inside `DSFormCard`.
struct DSActionRow: View {
    enum Style {
        /// Icon and title in the brand tint. Default for creation actions.
        case tinted
        case destructive
        /// Tinted icon with regular label text, for actions inside an information card.
        case neutral

        var iconColor: Color {
            self == .destructive ? Color.danger : Color.tint
        }

        var titleColor: Color {
            switch self {
            case .tinted: Color.tint
            case .destructive: Color.danger
            case .neutral: Color.label
            }
        }
    }

    let title: String
    var subtitle: String? = nil
    let systemImage: String
    var style: Style = .tinted
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DSActionLabel(title: title, subtitle: subtitle, systemImage: systemImage, style: style)
        }
        .buttonStyle(.plain)
    }
}

/// Content of `DSActionRow`, also usable as the label of system controls such as `ShareLink`.
struct DSActionLabel: View {
    let title: String
    var subtitle: String? = nil
    let systemImage: String
    var style: DSActionRow.Style = .tinted

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: systemImage)
                .font(.body.weight(.medium))
                .foregroundStyle(style.iconColor)
                .frame(width: DSSpacing.iconSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.body)
                    .foregroundStyle(style.titleColor)
                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, subtitle == nil ? 0 : DSSpacing.sm)
        .frame(minHeight: DSSpacing.rowHeight)
        .contentShape(Rectangle())
    }
}

#Preview {
    DSFormCard {
        DSActionRow(title: AppStrings.addProduct, systemImage: "plus") {}
        DSActionRow(title: AppStrings.deleteProduct, systemImage: "trash", style: .destructive) {}
        DSActionRow(title: AppStrings.sendInvoice, subtitle: AppStrings.sendInvoiceHint, systemImage: "square.and.arrow.up", style: .neutral) {}
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
