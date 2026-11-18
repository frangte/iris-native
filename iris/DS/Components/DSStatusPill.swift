//
//  DSStatusPill.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Small capsule tag for a state such as "Mới" or "Trễ hẹn". Not interactive.
struct DSStatusPill: View {
    enum Style {
        case tint
        case danger
        case success
        case neutral
    }

    let title: String
    var style: Style = .tint

    var body: some View {
        Text(title)
            .font(DSFont.captionEmphasized)
            .foregroundStyle(foreground)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .tint: Color.tint
        case .danger: Color.danger
        case .success: Color.success
        case .neutral: Color.secondaryLabel
        }
    }

    private var background: Color {
        switch style {
        case .tint: Color.tintSoft
        case .danger: Color.dangerSoft
        case .success: Color.success.opacity(0.12)
        case .neutral: Color.fill
        }
    }
}

#Preview {
    HStack(spacing: DSSpacing.sm) {
        DSStatusPill(title: AppStrings.statusNew)
        DSStatusPill(title: AppStrings.lateTag, style: .danger)
        DSStatusPill(title: AppStrings.delivered, style: .success)
        DSStatusPill(title: AppStrings.cancelled, style: .neutral)
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
