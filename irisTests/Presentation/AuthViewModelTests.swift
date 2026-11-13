//
//  AuthViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

import Testing
@testable import iris

@MainActor
struct AuthViewModelTests {
    /// Captures the session handed to `onAuthenticated`.
    private final class SessionSink {
        var received: AuthSession?
    }

    private let repository = MockAuthRepository()
    private let sink = SessionSink()
    private let viewModel: AuthViewModel

    init() {
        viewModel = Self.makeViewModel(repository: repository, sink: sink)
    }

    @Test func startsAtEmailStep() {
        #expect(viewModel.step == .requestCode)
        #expect(viewModel.content.inputKind == .email)
        #expect(viewModel.content.secondaryTitle == nil)
        #expect(viewModel.isPrimaryEnabled == false)
    }

    @Test func invalidEmailShowsErrorAndStays() async {
        viewModel.input = "khong-phai-email"
        await viewModel.submit()

        #expect(viewModel.step == .requestCode)
        #expect(viewModel.errorMessage == AppStrings.invalidEmail)
        #expect(repository.sentEmails.isEmpty)
    }

    @Test func validEmailMovesToCodeStep() async {
        viewModel.input = "ten@email.com"
        #expect(viewModel.isPrimaryEnabled)

        await viewModel.submit()

        #expect(viewModel.step == .verifyCode(Email("ten@email.com")!))
        #expect(viewModel.input.isEmpty)
        #expect(viewModel.content.inputKind == .oneTimeCode)
        #expect(viewModel.content.secondaryTitle == AppStrings.changeEmailOrResendCode)
        #expect(repository.sentEmails.map(\.value) == ["ten@email.com"])
    }

    @Test func codeInputKeepsOnlySixDigits() async {
        await moveToCodeStep()

        viewModel.input = "12ab34567"

        #expect(viewModel.input == "123456")
    }

    @Test func typingClearsError() async {
        viewModel.input = "sai"
        await viewModel.submit()
        #expect(viewModel.errorMessage != nil)

        viewModel.input = "sai@email.com"

        #expect(viewModel.errorMessage == nil)
    }

    @Test func wrongCodeShowsError() async {
        await moveToCodeStep()
        repository.verifyResult = .failure(AuthError.invalidCode)

        viewModel.input = "000000"
        await viewModel.submit()

        #expect(viewModel.errorMessage == AppStrings.invalidCode)
        #expect(sink.received == nil)
    }

    @Test func correctCodeReportsSession() async {
        await moveToCodeStep()
        let email = Email("ten@email.com")!
        let session = AuthSession(email: email, token: "token")
        repository.verifyResult = .success(session)

        viewModel.input = "123456"
        await viewModel.submit()

        #expect(sink.received == session)
        #expect(viewModel.errorMessage == nil)
        #expect(repository.verifiedCodes.first?.code.value == "123456")
    }

    @Test func goBackRestoresEmailForEditing() async {
        await moveToCodeStep()

        viewModel.goBackToEmail()

        #expect(viewModel.step == .requestCode)
        #expect(viewModel.input == "ten@email.com")
    }

    @Test func debugHintAppearsInCodeStepFooter() async {
        let hintedViewModel = Self.makeViewModel(repository: repository, sink: sink, debugCodeHint: "123456")
        hintedViewModel.input = "ten@email.com"
        await hintedViewModel.submit()

        #expect(hintedViewModel.content.footer == "\(AppStrings.devCodeHint) 123456")
    }

    // MARK: - Helpers

    private static func makeViewModel(
        repository: MockAuthRepository,
        sink: SessionSink,
        debugCodeHint: String? = nil
    ) -> AuthViewModel {
        AuthViewModel(
            requestLoginCode: RequestLoginCodeUseCase(repository: repository),
            verifyLoginCode: VerifyLoginCodeUseCase(repository: repository),
            debugCodeHint: debugCodeHint,
            onAuthenticated: { sink.received = $0 }
        )
    }

    private func moveToCodeStep() async {
        viewModel.input = "ten@email.com"
        await viewModel.submit()
    }
}
