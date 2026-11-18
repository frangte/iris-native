//
//  OrderError+Message.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// User-facing text for order validation and lookup failures.
extension OrderError {
    var message: String {
        switch self {
        case .noItems: AppStrings.addAtLeastOne
        case .missingItemName: AppStrings.productNameRequired
        case .endTimeNotAfterStart: AppStrings.endTimeMustAfterStartTime
        case .discountExceedsTotal: AppStrings.discountExceedsTotal
        case .depositExceedsTotal: AppStrings.depositExceedTheOrderTotal
        case .missingRecipientName: AppStrings.recipientNameRequired
        case .notFound: AppStrings.orderNotFound
        }
    }
}
