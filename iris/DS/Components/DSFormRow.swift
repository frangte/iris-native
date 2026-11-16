//
//  DSFormRow.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Single form line: fixed-width label on the left, text field on the right.
/// Pass `label: nil` for a full-width field. Intended to be placed inside `DSFormCard`.
struct DSFormRow: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var disablesAutocorrection = false
    /// `.vertical` grows the field from two up to six lines for free-form notes.
    var axis: Axis = .horizontal

    /// Shared label column width so fields in one card line up.
    private let labelWidth: CGFloat = 104
    /// Multi-line fields reserve this many lines so long placeholders stay fully visible.
    private let multilineRange = 2...6

    private var isMultiline: Bool { axis == .vertical }

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: DSSpacing.md) {
            if let label {
                Text(label)
                    .font(DSFont.body)
                    .foregroundStyle(Color.label)
                    .frame(width: labelWidth, alignment: .leading)
            }

            field
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, isMultiline ? DSSpacing.md : 0)
        .frame(minHeight: DSSpacing.rowHeight)
    }

    @ViewBuilder
    private var field: some View {
        if isMultiline {
            // The system placeholder of a vertical-axis field truncates to one line,
            // so draw a wrapping placeholder ourselves and give the field an empty one.
            TextField("", text: $text, axis: .vertical)
                .lineLimit(multilineRange)
                .modifier(InputTraits(row: self))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(DSFont.body)
                            .foregroundStyle(Color.placeholder)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
        } else {
            TextField(placeholder, text: $text)
                .lineLimit(1)
                .modifier(InputTraits(row: self))
        }
    }

    /// Keyboard and text traits shared by both field variants.
    private struct InputTraits: ViewModifier {
        let row: DSFormRow

        func body(content: Content) -> some View {
            content
                .font(DSFont.body)
                .foregroundStyle(Color.label)
                .keyboardType(row.keyboardType)
                .textContentType(row.contentType)
                .textInputAutocapitalization(row.autocapitalization)
                .autocorrectionDisabled(row.disablesAutocorrection)
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var note = ""
    VStack(spacing: DSSpacing.md) {
        DSFormRow(label: AppStrings.address, placeholder: AppStrings.addressPlaceHolder, text: $text)
            .background(Color.cell)
        DSFormRow(label: nil, placeholder: AppStrings.productNamePlaceholder, text: $text)
            .background(Color.cell)
        DSFormRow(label: AppStrings.note, placeholder: AppStrings.notePlaceholder, text: $note, axis: .vertical)
            .background(Color.cell)
    }
    .padding(DSSpacing.screenPadding)
}
