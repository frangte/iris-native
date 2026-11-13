//
//  DSFormRow.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Single form line: fixed-width label on the left, text field on the right.
/// Intended to be placed inside `DSFormCard`.
struct DSFormRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var disablesAutocorrection = false

    /// Shared label column width so fields in one card line up.
    private let labelWidth: CGFloat = 104

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Text(label)
                .font(DSFont.body)
                .foregroundStyle(Color.label)
                .frame(width: labelWidth, alignment: .leading)

            TextField(placeholder, text: $text)
                .font(DSFont.body)
                .foregroundStyle(Color.label)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disablesAutocorrection)
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .frame(minHeight: DSSpacing.rowHeight)
    }
}

#Preview {
    @Previewable @State var text = ""
    DSFormRow(label: AppStrings.address, placeholder: AppStrings.addressPlaceHolder, text: $text)
        .background(Color.cell)
        .padding(DSSpacing.screenPadding)
}
