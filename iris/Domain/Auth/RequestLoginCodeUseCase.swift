//
//  RequestLoginCodeUseCase.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Login step 1: validate the email and request a code.
struct RequestLoginCodeUseCase {
    let repository: AuthRepository

    /// Returns the normalized `Email` so the verification step can reuse it.
    func execute(rawEmail: String) async throws -> Email {
        guard let email = Email(rawEmail) else { throw AuthError.invalidEmail }
        try await repository.sendLoginCode(to: email)
        return email
    }
}
