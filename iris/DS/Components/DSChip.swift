//
//  DSChip.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Selectable capsule used for single-choice option groups such as order source or time slot.
struct DSChip: View {
    let title: String
    let isSelected: Bool
    /// Tighter horizontal padding for chips that share a line with other controls.
    var isCompact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.subhead.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.onTint : Color.label)
                .padding(.horizontal, isCompact ? DSSpacing.md : DSSpacing.lg)
                .frame(height: DSSpacing.smallButtonHeight)
                .background(isSelected ? Color.tint : Color.fill, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: DSSpacing.sm) {
        DSChip(title: AppStrings.sourceZalo, isSelected: true) {}
        DSChip(title: AppStrings.sourceMessenger, isSelected: false) {}
        DSChip(title: AppStrings.sourceOther, isSelected: false, isCompact: true) {}
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
