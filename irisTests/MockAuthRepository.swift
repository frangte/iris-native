//
//  MockAuthRepository.swift
//  irisTests
//
//  Created by SonnyHoang on 12/11/26.
//

@testable import iris

/// Test double that records calls and returns preconfigured results.
@MainActor
final class MockAuthRepository: AuthRepository {
    private(set) var sentEmails: [Email] = []
    private(set) var verifiedCodes: [(code: LoginCode, email: Email)] = []

    /// Error thrown when sending a code. `nil` means success.
    var sendError: Error?
    /// Result returned when verifying a code.
    var verifyResult: Result<AuthSession, Error>

    init(verifyResult: Result<AuthSession, Error> = .failure(AuthError.invalidCode)) {
        self.verifyResult = verifyResult
    }

    func sendLoginCode(to email: Email) async throws {
        if let sendError { throw sendError }
        sentEmails.append(email)
    }

    func verifyLoginCode(_ code: LoginCode, for email: Email) async throws -> AuthSession {
        verifiedCodes.append((code, email))
        return try verifyResult.get()
    }
}
