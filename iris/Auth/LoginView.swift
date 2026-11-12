//
//  LoginView.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var errorMessage: String?

    /// Bo góc dùng chung cho ô nhập, nút và banner lỗi.
    private let cornerRadius: CGFloat = DSSpacing.lg

    private var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let at = trimmed.firstIndex(of: "@") else { return false }
        let domain = trimmed[trimmed.index(after: at)...]
        return at != trimmed.startIndex && domain.contains(".") && !domain.hasSuffix(".")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            header

            emailSection
                .padding(.top, DSSpacing.xxl)

            sendCodeButton
                .padding(.top, DSSpacing.xl)

            if let errorMessage {
                errorBanner(errorMessage)
                    .padding(.top, DSSpacing.md)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground.ignoresSafeArea())
        .animation(.default, value: errorMessage)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Floied")
                .font(DSFont.displayLarge)
                .foregroundStyle(Color.label)
            Text(AppStrings.orderBookTitle)
                .font(DSFont.headlineMedium.weight(.regular))
                .foregroundStyle(Color.secondaryLabel)
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(AppStrings.loginWithEmail.uppercased())
                .font(DSFont.bodyMedium)
                .foregroundStyle(Color.secondaryLabel)
                .padding(.horizontal, DSSpacing.md)

            TextField(AppStrings.emailPlaceHolder, text: $email)
                .font(DSFont.headlineMedium.weight(.regular))
                .foregroundStyle(Color.label)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, DSSpacing.md)
                .frame(height: 56)
                .background(Color.cell, in: RoundedRectangle(cornerRadius: cornerRadius))
                .onChange(of: email) { _, _ in
                    errorMessage = nil
                }

            Text(AppStrings.codeSentDesc)
                .font(DSFont.bodyMedium)
                .foregroundStyle(Color.secondaryLabel)
                .padding(.horizontal, DSSpacing.md)
        }
    }

    private var sendCodeButton: some View {
        Button(action: sendCode) {
            Text(AppStrings.sendCode)
                .font(DSFont.headlineMedium)
                .foregroundStyle(Color.onTint)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Color.tint.opacity(isEmailValid ? 1 : 0.5),
                    in: RoundedRectangle(cornerRadius: cornerRadius)
                )
        }
        .buttonStyle(.plain)
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(DSFont.headlineMedium.weight(.regular))
            .foregroundStyle(Color.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.lg)
            .background(Color.dangerSoft, in: RoundedRectangle(cornerRadius: cornerRadius))
            .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Actions

    private func sendCode() {
        guard isEmailValid else {
            errorMessage = AppStrings.invalidEmail
            return
        }
        errorMessage = nil
        // TODO: gọi API gửi mã 6 số tới email.
    }
}

#Preview {
    LoginView()
}
