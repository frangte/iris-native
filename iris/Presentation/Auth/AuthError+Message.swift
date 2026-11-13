//
//  AuthError+Message.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Maps login errors to display text. Lives in Presentation so Domain stays free of UI strings.
extension AuthError {
    var message: String {
        switch self {
        case .invalidEmail: AppStrings.invalidEmail
        case .invalidCode: AppStrings.invalidCode
        case .codeExpired: AppStrings.codeExpired
        }
    }
}
