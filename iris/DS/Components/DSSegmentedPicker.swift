//
//  DSSegmentedPicker.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Pill-shaped segmented control with a tinted thumb that slides between segments.
/// Custom rather than the system `Picker` so the thumb can carry the brand tint.
/// Segments share the width equally.
struct DSSegmentedPicker<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String

    /// Shared identity for the thumb so it animates from one segment to the next.
    @Namespace private var thumbNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.snappy(duration: 0.3)) { selection = option }
                } label: {
                    Text(title(option))
                        .font(DSFont.subhead.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.onTint : Color.label)
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.smallButtonHeight - 4)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .background {
                    if isSelected {
                        Color.clear
                            .glassEffect(.regular.tint(Color.tint).interactive(), in: Capsule())
                            .matchedGeometryEffect(id: "thumb", in: thumbNamespace)
                    }
                }
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(2)
        .background(Color.fill, in: Capsule())
    }
}

#Preview {
    @Previewable @State var method: DeliveryMethod = .delivery
    DSSegmentedPicker(options: DeliveryMethod.allCases, selection: $method) { $0.title }
        .padding(DSSpacing.screenPadding)
        .background(Color.groupedBackground)
}
