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
        case tinted
        case destructive
    }

    let title: String
    let systemImage: String
    var style: Style = .tinted
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .frame(width: DSSpacing.iconSize)
                Text(title)
                    .font(DSFont.body)
                Spacer(minLength: 0)
            }
            .foregroundStyle(style == .destructive ? Color.danger : Color.tint)
            .padding(.horizontal, DSSpacing.controlInset)
            .frame(minHeight: DSSpacing.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DSFormCard {
        DSActionRow(title: AppStrings.addProduct, systemImage: "plus") {}
        DSActionRow(title: AppStrings.deleteProduct, systemImage: "trash", style: .destructive) {}
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
