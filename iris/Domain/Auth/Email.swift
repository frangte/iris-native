//
//  Email.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// A normalized, format-checked email address.
/// Only constructible through `init?(_:)`, so every `Email` value is valid.
struct Email: Equatable, Hashable {
    let value: String

    /// Returns `nil` unless the trimmed input looks like `local@domain.tld`.
    init?(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let at = trimmed.firstIndex(of: "@"), at != trimmed.startIndex else { return nil }

        let domain = trimmed[trimmed.index(after: at)...]
        guard domain.contains("."), !domain.hasPrefix("."), !domain.hasSuffix(".") else { return nil }

        value = trimmed
    }
}
