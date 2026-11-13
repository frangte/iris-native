//
//  DSTonalButton.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Secondary filled button: soft tint background with tinted text.
/// Same sizing and loading behavior as `DSPrimaryButton`.
struct DSTonalButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(DSFont.headline)
                    .foregroundStyle(Color.tint)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(Color.tint)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeight)
            .background(
                Color.tint.opacity(0.12),
                in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius)
            )
            .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: DSSpacing.md) {
        DSTonalButton(title: AppStrings.joinShop, isEnabled: true, isLoading: false) {}
        DSTonalButton(title: AppStrings.joinShop, isEnabled: false, isLoading: false) {}
        DSTonalButton(title: AppStrings.joinShop, isEnabled: true, isLoading: true) {}
    }
    .padding(DSSpacing.screenPadding)
}
