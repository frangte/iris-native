//
//  OrderInput.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation

/// One product line as typed in the form. Blank lines are allowed while editing.
struct OrderItemInput: Identifiable, Equatable {
    let id: UUID
    var name = ""
    var quantity = 1
    /// Price per unit in VND.
    var unitPrice = 0

    init(id: UUID = UUID(), name: String = "", quantity: Int = 1, unitPrice: Int = 0) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
    }

    var total: Int {
        quantity * unitPrice
    }
}

/// Raw, unvalidated values of the new-order form. `OrderDraft` validates them.
struct OrderInput: Equatable {
    static let defaultTime = TimeOfDay(hour: 9)

    // Customer
    var customerName = ""
    var customerPhone = ""
    var source: OrderSource = .zalo

    // Products
    var items: [OrderItemInput] = [OrderItemInput()]

    // Delivery
    var deliveryMethod: DeliveryMethod = .delivery
    /// Day of delivery or pickup. Only the calendar day matters.
    var deliveryDate: Date
    /// False means "no fixed time"; the start and end values are then ignored.
    var hasTimeWindow = false
    var startTime = OrderInput.defaultTime
    var endTime = OrderInput.defaultTime

    // Recipient
    var address = ""
    /// False means the recipient is the customer who placed the order.
    var hasSeparateRecipient = false
    var recipientName = ""
    var recipientPhone = ""

    // Notes
    var cardMessage = ""
    var note = ""

    // Payment, in VND
    var shippingFee = 0
    var discount = 0
    var deposit = 0

    init(deliveryDate: Date) {
        self.deliveryDate = deliveryDate
    }

    var timeWindow: DeliveryTimeWindow? {
        hasTimeWindow ? DeliveryTimeWindow(start: startTime, end: endTime) : nil
    }

    /// Live totals over every line, including ones still being typed.
    var pricing: OrderPricing {
        OrderPricing(
            subtotal: items.reduce(0) { $0 + $1.total },
            shippingFee: shippingFee,
            discount: discount,
            deposit: deposit
        )
    }
}
