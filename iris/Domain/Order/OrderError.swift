//
//  OrderError.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Validation failures when building an order from the form. Messages are mapped in Presentation.
enum OrderError: Error, Equatable {
    /// No product line has a name.
    case noItems
    /// A line has a price but no product name.
    case missingItemName
    /// The time window ends at or before it starts.
    case endTimeNotAfterStart
    /// Discount is larger than products plus shipping.
    case discountExceedsTotal
    /// Deposit is larger than the order total.
    case depositExceedsTotal
    /// A separate recipient was requested without a name.
    case missingRecipientName
}
