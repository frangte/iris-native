//
//  VerifyLoginCodeUseCase.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Login step 2: validate the code format and verify it with the repository.
struct VerifyLoginCodeUseCase {
    let repository: AuthRepository

    func execute(rawCode: String, email: Email) async throws -> AuthSession {
        guard let code = LoginCode(rawCode) else { throw AuthError.invalidCode }
        return try await repository.verifyLoginCode(code, for: email)
    }
}
