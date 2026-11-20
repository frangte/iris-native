//
//  ShopInvite.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import Foundation

/// An invite code the owner issued. Anyone can use it until it expires or is revoked.
struct ShopInvite: Equatable, Hashable, Identifiable {
    /// How long a new code stays usable.
    static let lifetime: TimeInterval = 7 * 24 * 60 * 60

    let code: InviteCode
    let expiresAt: Date
    /// How many people joined with this code so far.
    let useCount: Int

    var id: String { code.value }

    func isActive(at now: Date) -> Bool {
        now < expiresAt
    }
}
