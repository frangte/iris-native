//
//  AuthRepository.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Domain boundary for authentication. Data layer provides the implementation
/// (real API, in-memory stand-in for development, mock for tests).
protocol AuthRepository {
    /// Sends a login code to the email address.
    func sendLoginCode(to email: Email) async throws

    /// Verifies the code and returns the authenticated session.
    func verifyLoginCode(_ code: LoginCode, for email: Email) async throws -> AuthSession
}
