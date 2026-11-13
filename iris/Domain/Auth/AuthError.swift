//
//  AuthError.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Business errors of the login flow. Presentation maps them to display text.
enum AuthError: Error, Equatable {
    /// Email is not in a valid format.
    case invalidEmail
    /// Code is not six digits or does not match the issued code.
    case invalidCode
    /// No code was issued for this email, or it has expired.
    case codeExpired
}
