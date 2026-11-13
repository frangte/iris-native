//
//  AuthField.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Login input: uppercase label, rounded text field, and a footer note.
struct AuthField: View {
    let label: String
    let placeholder: String
    let footer: String?
    let inputKind: AuthStepContent.InputKind
    @Binding var text: String

    var body: some View {
        DSFormSection(title: label, footer: footer) {
            TextField(placeholder, text: $text)
                .font(DSFont.body)
                .foregroundStyle(Color.label)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, DSSpacing.controlInset)
                .frame(height: DSSpacing.rowHeight)
                .background(Color.cell, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
        }
    }

    private var keyboardType: UIKeyboardType {
        switch inputKind {
        case .email: .emailAddress
        case .oneTimeCode: .numberPad
        }
    }

    private var textContentType: UITextContentType {
        switch inputKind {
        case .email: .emailAddress
        case .oneTimeCode: .oneTimeCode
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    AuthField(
        label: AppStrings.loginWithEmail,
        placeholder: AppStrings.emailPlaceHolder,
        footer: AppStrings.codeSentDesc,
        inputKind: .email,
        text: $text
    )
    .padding(DSSpacing.screenPadding)
}
