//
//  ShopError.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Business errors of the shop onboarding flow. Presentation maps them to display text.
enum ShopError: Error, Equatable {
    /// Shop name is empty after trimming.
    case emptyName
    /// Invite code is not six alphanumeric characters.
    case invalidInviteCode
    /// No shop matches the invite code.
    case inviteCodeNotFound
}
