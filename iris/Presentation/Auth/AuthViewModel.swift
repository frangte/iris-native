//
//  AuthViewModel.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Observation

/// Drives the two-step login flow (enter email, enter code) on a single screen.
@Observable
final class AuthViewModel {
    enum Step: Hashable {
        case requestCode
        /// A code was sent to this email; waiting for the user to type it.
        case verifyCode(Email)
    }

    private(set) var step: Step = .requestCode
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    /// Text of the single input field shared by both steps.
    /// In the code step only digits are kept, capped at `LoginCode.length`.
    var input: String {
        get { rawInput }
        set { updateInput(newValue) }
    }
    private var rawInput = ""

    private let requestLoginCode: RequestLoginCodeUseCase
    private let verifyLoginCode: VerifyLoginCodeUseCase
    /// Development-only hint showing the accepted code. `nil` in production.
    private let debugCodeHint: String?
    /// Called once the code is verified. The owner decides what happens next.
    private let onAuthenticated: (AuthSession) -> Void

    init(
        requestLoginCode: RequestLoginCodeUseCase,
        verifyLoginCode: VerifyLoginCodeUseCase,
        debugCodeHint: String? = nil,
        onAuthenticated: @escaping (AuthSession) -> Void
    ) {
        self.requestLoginCode = requestLoginCode
        self.verifyLoginCode = verifyLoginCode
        self.debugCodeHint = debugCodeHint
        self.onAuthenticated = onAuthenticated
    }

    // MARK: - Display data

    var content: AuthStepContent {
        switch step {
        case .requestCode:
            AuthStepContent(
                inputKind: .email,
                fieldLabel: AppStrings.loginWithEmail,
                placeholder: AppStrings.emailPlaceHolder,
                footer: AppStrings.codeSentDesc,
                primaryTitle: AppStrings.sendCode,
                secondaryTitle: nil
            )
        case .verifyCode(let email):
            AuthStepContent(
                inputKind: .oneTimeCode,
                fieldLabel: "\(AppStrings.codeSentToEmail) \(email.value)",
                placeholder: AppStrings.sixDigits,
                footer: debugCodeHint.map { "\(AppStrings.devCodeHint) \($0)" } ?? AppStrings.codeExpiredIn,
                primaryTitle: AppStrings.login,
                secondaryTitle: AppStrings.changeEmailOrResendCode
            )
        }
    }

    /// The primary button is fully opaque only when the input can be submitted.
    var isPrimaryEnabled: Bool {
        switch step {
        case .requestCode: Email(rawInput) != nil
        case .verifyCode: LoginCode(rawInput) != nil
        }
    }

    // MARK: - Actions

    /// Sends the code (step 1) or verifies it (step 2), depending on the current step.
    func submit() async {
        guard !isLoading else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            switch step {
            case .requestCode:
                let email = try await requestLoginCode.execute(rawEmail: rawInput)
                rawInput = ""
                step = .verifyCode(email)
            case .verifyCode(let email):
                let session = try await verifyLoginCode.execute(rawCode: rawInput, email: email)
                onAuthenticated(session)
            }
        } catch let error as AuthError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    /// Returns to the email step, keeping the previous email so it can be edited or resent.
    func goBackToEmail() {
        guard case .verifyCode(let email) = step else { return }
        step = .requestCode
        rawInput = email.value
        errorMessage = nil
    }

    // MARK: - Private

    private func updateInput(_ newValue: String) {
        errorMessage = nil
        switch step {
        case .requestCode:
            rawInput = newValue
        case .verifyCode:
            rawInput = String(newValue.filter(\.isNumber).prefix(LoginCode.length))
        }
    }
}
