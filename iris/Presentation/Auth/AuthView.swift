//
//  AuthView.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Login screen shared by the email step and the code step.
/// Everything that differs between steps comes from `AuthStepContent` provided by the view model.
struct AuthView: View {
    @State private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            AuthHeader()

            stepForm
                .padding(.top, DSSpacing.xxl)
                // Changing identity per step lets SwiftUI run the slide transition between steps.
                .id(viewModel.step)
                .transition(stepTransition)

            if let errorMessage = viewModel.errorMessage {
                DSErrorBanner(message: errorMessage)
                    .padding(.top, DSSpacing.md)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, DSSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground.ignoresSafeArea())
        .animation(.default, value: viewModel.step)
        .animation(.default, value: viewModel.errorMessage)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var stepForm: some View {
        let content = viewModel.content

        VStack(alignment: .leading, spacing: 0) {
            AuthField(
                label: content.fieldLabel,
                placeholder: content.placeholder,
                footer: content.footer,
                inputKind: content.inputKind,
                text: $viewModel.input
            )

            DSPrimaryButton(
                title: content.primaryTitle,
                isEnabled: viewModel.isPrimaryEnabled,
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.submit() }
            }
            .padding(.top, DSSpacing.lg)

            if let secondaryTitle = content.secondaryTitle {
                DSTextButton(title: secondaryTitle, action: viewModel.goBackToEmail)
                    .padding(.top, DSSpacing.md)
            }
        }
    }

    /// The email step slides in from the leading edge, the code step from the trailing edge.
    private var stepTransition: AnyTransition {
        let edge: Edge = viewModel.step == .requestCode ? .leading : .trailing
        return .move(edge: edge).combined(with: .opacity)
    }
}

#Preview {
    let repository = InMemoryAuthRepository(simulatedDelay: .zero)
    AuthView(
        viewModel: AuthViewModel(
            requestLoginCode: RequestLoginCodeUseCase(repository: repository),
            verifyLoginCode: VerifyLoginCodeUseCase(repository: repository),
            debugCodeHint: InMemoryAuthRepository.fixedCode,
            onAuthenticated: { _ in }
        )
    )
}
