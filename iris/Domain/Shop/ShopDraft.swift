//
//  ShopDraft.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Foundation

/// Validated input for creating a new shop. Only the name is required.
struct ShopDraft: Equatable {
    let name: String
    let phone: String?
    let address: String?

    /// Returns `nil` when the trimmed name is empty. Empty optional fields become `nil`.
    init?(name: String, phone: String, address: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        self.name = trimmedName
        self.phone = Self.optionalValue(phone)
        self.address = Self.optionalValue(address)
    }

    private static func optionalValue(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
