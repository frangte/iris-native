//
//  LoginCode.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// Six-digit login code delivered by email.
struct LoginCode: Equatable, Hashable {
    static let length = 6

    let value: String

    /// Returns `nil` unless the input is exactly six digits.
    init?(_ raw: String) {
        guard raw.count == Self.length, raw.allSatisfy(\.isNumber) else { return nil }
        value = raw
    }
}
