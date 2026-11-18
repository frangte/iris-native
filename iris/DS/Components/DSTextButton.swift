//
//  DSTextButton.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Borderless text button for low-emphasis actions such as "change email" or "log out".
struct DSTextButton: View {
    enum Style {
        case tint
        /// Red text for irreversible actions like deleting an order.
        case destructive
    }

    let title: String
    var style: Style = .tint
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.headline)
                .foregroundStyle(style == .destructive ? Color.danger : Color.tint)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        DSTextButton(title: AppStrings.logout) {}
        DSTextButton(title: AppStrings.deleteForever, style: .destructive) {}
    }
    .padding(DSSpacing.screenPadding)
}
