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
    enum Style {
        case tint
        /// Soft red background for actions like cancelling an order.
        case destructive
    }

    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    var style: Style = .tint
    /// Optional SF Symbol shown before the title.
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: DSSpacing.sm) {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title)
                }
                .font(DSFont.headline)
                .foregroundStyle(foreground)
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(foreground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeight)
            .background(background, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
            .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private var foreground: Color {
        style == .destructive ? Color.danger : Color.tint
    }

    private var background: Color {
        style == .destructive ? Color.dangerSoft : Color.tint.opacity(0.12)
    }
}

#Preview {
    VStack(spacing: DSSpacing.md) {
        DSTonalButton(title: AppStrings.joinShop, isEnabled: true, isLoading: false) {}
        DSTonalButton(title: AppStrings.joinShop, isEnabled: false, isLoading: false) {}
        DSTonalButton(title: AppStrings.joinShop, isEnabled: true, isLoading: true) {}
        DSTonalButton(title: AppStrings.cancelOrder, isEnabled: true, isLoading: false, style: .destructive) {}
        DSTonalButton(title: AppStrings.logout, isEnabled: true, isLoading: false, style: .destructive, systemImage: "rectangle.portrait.and.arrow.right") {}
    }
    .padding(DSSpacing.screenPadding)
}
