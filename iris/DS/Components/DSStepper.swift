//
//  DSStepper.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Compact minus / value / plus control for small integer quantities.
struct DSStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...99

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            stepButton(systemImage: "minus", isEnabled: value > range.lowerBound) { value -= 1 }

            Text(String(value))
                .font(DSFont.headline.money)
                .foregroundStyle(Color.label)
                .frame(minWidth: 24)
                .contentTransition(.numericText())

            stepButton(systemImage: "plus", isEnabled: value < range.upperBound) { value += 1 }
        }
        .animation(.snappy(duration: 0.15), value: value)
    }

    private func stepButton(systemImage: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.medium))
                .foregroundStyle(isEnabled ? Color.label : Color.tertiaryLabel)
                .frame(width: DSSpacing.smallButtonHeight, height: DSSpacing.smallButtonHeight)
                .background(Color.fill, in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    @Previewable @State var quantity = 1
    DSFormCard {
        DSRow(label: AppStrings.amount) {
            DSStepper(value: $quantity)
        }
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
