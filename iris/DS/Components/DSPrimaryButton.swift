//
//  DSPrimaryButton.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Filled call-to-action button. Dims when `isEnabled` is false and shows a spinner while loading.
/// Stays tappable when dimmed so the caller can surface a validation message.
struct DSPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(DSFont.headline)
                    .foregroundStyle(Color.onTint)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(Color.onTint)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeight)
            .background(
                Color.tint.opacity(isEnabled ? 1 : 0.5),
                in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: DSSpacing.md) {
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: true, isLoading: false) {}
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: false, isLoading: false) {}
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: true, isLoading: true) {}
    }
    .padding(DSSpacing.screenPadding)
}
