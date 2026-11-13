//
//  ShopError+Message.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Maps shop errors to display text. Lives in Presentation so Domain stays free of UI strings.
extension ShopError {
    var message: String {
        switch self {
        case .emptyName: AppStrings.shopNameRequired
        case .invalidInviteCode: AppStrings.invalidInvitationCode
        case .inviteCodeNotFound: AppStrings.invitationCodeNotFound
        }
    }
}
