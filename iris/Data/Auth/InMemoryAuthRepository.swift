//
//  InMemoryAuthRepository.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// Development stand-in that never touches the network and accepts one fixed code.
/// Replace with an API-backed repository once the backend is ready.
final class InMemoryAuthRepository: AuthRepository {
    /// Code that is always accepted in development builds.
    static let fixedCode = "123456"

    /// Emails that have been "sent" a code and are waiting for verification.
    private var pendingEmails: Set<Email> = []
    /// Artificial latency so loading states are visible in the UI.
    private let simulatedDelay: Duration

    init(simulatedDelay: Duration = .milliseconds(400)) {
        self.simulatedDelay = simulatedDelay
    }

    func sendLoginCode(to email: Email) async throws {
        try await Task.sleep(for: simulatedDelay)
        pendingEmails.insert(email)
    }

    func verifyLoginCode(_ code: LoginCode, for email: Email) async throws -> AuthSession {
        try await Task.sleep(for: simulatedDelay)
        guard pendingEmails.contains(email) else { throw AuthError.codeExpired }
        guard code.value == Self.fixedCode else { throw AuthError.invalidCode }
        pendingEmails.remove(email)
        return AuthSession(email: email, token: UUID().uuidString)
    }
}
