//
//  DSTextButton.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Borderless text button for low-emphasis actions such as "change email" or "log out".
struct DSTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.headline)
                .foregroundStyle(Color.tint)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DSTextButton(title: AppStrings.logout) {}
        .padding(DSSpacing.screenPadding)
}
