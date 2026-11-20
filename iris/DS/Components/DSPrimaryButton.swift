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
    /// Optional SF Symbol shown before the title.
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DSPrimaryLabel(title: title, systemImage: systemImage, isEnabled: isEnabled, isLoading: isLoading)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

/// Content of `DSPrimaryButton`, also usable as the label of system controls such as `ShareLink`.
struct DSPrimaryLabel: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled = true
    var isLoading = false

    var body: some View {
        ZStack {
            HStack(spacing: DSSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
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
        .contentShape(RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
    }
}

#Preview {
    VStack(spacing: DSSpacing.md) {
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: true, isLoading: false) {}
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: false, isLoading: false) {}
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: true, isLoading: true) {}
        DSPrimaryButton(title: AppStrings.sendCode, isEnabled: true, isLoading: false, systemImage: "square.and.arrow.up") {}
    }
    .padding(DSSpacing.screenPadding)
}
