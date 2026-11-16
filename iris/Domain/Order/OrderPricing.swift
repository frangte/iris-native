//
//  OrderPricing.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Money math for one order, in VND. Shared by the live form totals and the saved order.
struct OrderPricing: Equatable, Hashable {
    /// Sum of quantity × unit price across all product lines.
    let subtotal: Int
    let shippingFee: Int
    let discount: Int
    let deposit: Int

    /// Amount the customer owes in total.
    var total: Int {
        subtotal + shippingFee - discount
    }

    /// Amount still to collect after the deposit.
    var remaining: Int {
        total - deposit
    }
}
