//
//  InviteCode.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// Six-character alphanumeric code a shop owner shares to invite members.
struct InviteCode: Equatable, Hashable {
    static let length = 6

    /// Normalized value: trimmed and uppercased.
    let value: String

    /// Returns `nil` unless the normalized input is exactly six letters or digits.
    init?(_ raw: String) {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalized.count == Self.length,
              normalized.allSatisfy({ $0.isLetter || $0.isNumber }) else { return nil }
        value = normalized
    }
}
