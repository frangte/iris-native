//
//  DeliveryMethod.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// How the flowers reach the customer.
enum DeliveryMethod: String, CaseIterable, Hashable {
    /// Shop or shipper brings the order to an address.
    case delivery
    /// Customer collects the order at the shop.
    case pickup
}
