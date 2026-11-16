//
//  OrderDraft.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation

/// A validated product line.
struct OrderLine: Equatable, Hashable {
    let name: String
    let quantity: Int
    let unitPrice: Int

    var total: Int {
        quantity * unitPrice
    }
}

/// Person receiving the flowers when it is not the customer who ordered.
struct OrderRecipient: Equatable, Hashable {
    let name: String
    let phone: String?
}

/// Validated order content ready to be stored. Built from `OrderInput`; throws `OrderError` on bad input.
struct OrderDraft: Equatable, Hashable {
    let customerName: String?
    let customerPhone: String?
    let source: OrderSource
    let items: [OrderLine]
    let deliveryMethod: DeliveryMethod
    let deliveryDate: Date
    let timeWindow: DeliveryTimeWindow?
    let address: String?
    /// `nil` when the recipient is the customer.
    let recipient: OrderRecipient?
    let cardMessage: String?
    let note: String?
    let pricing: OrderPricing

    init(_ input: OrderInput) throws {
        items = try Self.validatedItems(input.items)
        guard !items.isEmpty else { throw OrderError.noItems }

        if let window = input.timeWindow, !window.isValid {
            throw OrderError.endTimeNotAfterStart
        }

        let pricing = OrderPricing(
            subtotal: items.reduce(0) { $0 + $1.total },
            shippingFee: max(0, input.shippingFee),
            discount: max(0, input.discount),
            deposit: max(0, input.deposit)
        )
        guard pricing.discount <= pricing.subtotal + pricing.shippingFee else {
            throw OrderError.discountExceedsTotal
        }
        guard pricing.deposit <= pricing.total else {
            throw OrderError.depositExceedsTotal
        }

        if input.hasSeparateRecipient {
            guard let name = Self.optionalValue(input.recipientName) else {
                throw OrderError.missingRecipientName
            }
            recipient = OrderRecipient(name: name, phone: Self.optionalValue(input.recipientPhone))
        } else {
            recipient = nil
        }

        customerName = Self.optionalValue(input.customerName)
        customerPhone = Self.optionalValue(input.customerPhone)
        source = input.source
        deliveryMethod = input.deliveryMethod
        deliveryDate = input.deliveryDate
        timeWindow = input.timeWindow
        address = input.deliveryMethod == .delivery ? Self.optionalValue(input.address) : nil
        cardMessage = Self.optionalValue(input.cardMessage)
        note = Self.optionalValue(input.note)
        self.pricing = pricing
    }

    // MARK: - Private

    /// Drops fully blank lines, rejects priced lines without a name, and clamps quantity to at least 1.
    private static func validatedItems(_ inputs: [OrderItemInput]) throws -> [OrderLine] {
        try inputs.compactMap { item in
            guard let name = optionalValue(item.name) else {
                if item.unitPrice > 0 { throw OrderError.missingItemName }
                return nil
            }
            return OrderLine(name: name, quantity: max(1, item.quantity), unitPrice: max(0, item.unitPrice))
        }
    }

    private static func optionalValue(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
